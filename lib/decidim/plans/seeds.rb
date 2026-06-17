# frozen_string_literal: true

require "decidim/seeds"

module Decidim
  module Plans
    class Seeds < Decidim::Seeds
      def initialize(participatory_space:)
        @participatory_space = participatory_space
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def call
        step_settings = if participatory_space.allows_steps?
                          { participatory_space.active_step.id => { creation_enabled: true } }
                        else
                          {}
                        end

        # Create area taxonomies and filter
        area_taxonomy = create_taxonomy!(name: "Areas", parent: nil)
        area_parent = create_taxonomy!(name: ::Faker::Address.unique.city, parent: area_taxonomy)
        areas = 10.times.map do
          create_taxonomy!(name: ::Faker::Address.unique.community, parent: area_parent)
        end
        area_filter = create_taxonomy_filter!(
          root_taxonomy: area_taxonomy,
          taxonomies: areas.sample(3)
        )

        # Create category taxonomies and filter
        category_taxonomy = create_taxonomy!(name: "Categories", parent: nil)
        categories = 3.times.flat_map do
          sub_taxonomy = create_taxonomy!(name: ::Faker::Lorem.sentence(word_count: 5), parent: category_taxonomy)
          5.times.map do
            create_taxonomy!(name: ::Faker::Lorem.sentence(word_count: 5), parent: sub_taxonomy)
          end
        end
        category_filter = create_taxonomy_filter!(
          root_taxonomy: category_taxonomy,
          taxonomies: categories.sample(3)
        )

        # Component always uses category filter, 50% chance to include area filter
        selected_filters = [category_filter.id]
        selected_filters << area_filter.id if ::Faker::Boolean.boolean(true_ratio: 0.5)

        component = Decidim.traceability.perform_action!(
          "publish",
          Decidim::Component,
          admin_user,
          visibility: "all"
        ) do
          Decidim::Component.create!(
            name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :plans).i18n_name,
            manifest_name: :plans,
            published_at: Time.current,
            participatory_space:,
            settings: {
              multilingual_answers: false,
              taxonomy_filters: selected_filters,
              scope_id: participatory_space.scope&.id
            },
            step_settings:
          )
        end

        # Legacy category/scope setup — kept alongside taxonomies
        if participatory_space.scope
          scopes = participatory_space.scope.descendants
          global = participatory_space.scope
        else
          scopes = participatory_space.organization.scopes
          global = nil
        end

        Decidim::Plans::Section.create!(
          component:,
          body: Decidim::Faker::Localized.paragraph,
          help: Decidim::Faker::Localized.paragraph,
          mandatory: true,
          position: 0,
          handle: "title",
          section_type: "field_title"
        )

        Decidim::Plans::Section.create!(
          component:,
          body: Decidim::Faker::Localized.literal("Taxonomies"),
          help: Decidim::Faker::Localized.literal(""),
          mandatory: false,
          position: 1,
          handle: "taxonomy",
          section_type: "field_taxonomy"
        )

        5.times do |n|
          Decidim::Plans::Section.create!(
            component:,
            body: Decidim::Faker::Localized.paragraph,
            help: Decidim::Faker::Localized.paragraph,
            mandatory: false,
            position: n + 2,
            handle: "section_#{n}",
            section_type: "field_text_multiline"
          )
        end

        proposal_component = participatory_space.components.find_by(manifest_name: "proposals")
        proposals = if proposal_component
                      Decidim::Proposals::Proposal.where(component: proposal_component).to_a
                    else
                      []
                    end

        5.times do |n|
          state, answer = if n > 3
                            ["accepted", Decidim::Faker::Localized.sentence(word_count: 10)]
                          elsif n > 2
                            ["rejected", Decidim::Faker::Localized.sentence(word_count: 10)]
                          elsif n > 1
                            ["evaluating", nil]
                          else
                            [nil, nil]
                          end

          is_answered = !state.nil?
          is_closed = is_answered || rand < 0.5
          state = "evaluating" if is_closed && !is_answered

          plan = Decidim.traceability.perform_action!(
            "publish",
            Decidim::Plans::Plan,
            admin_user,
            visibility: "all"
          ) do
            plan = Decidim::Plans::Plan.new(
              component:,
              category: participatory_space.categories.sample,
              scope: ::Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
              title: Decidim::Faker::Localized.sentence(word_count: 2),
              state:,
              answer:,
              closed_at: is_closed ? Time.current : nil,
              answered_at: is_answered ? Time.current : nil,
              published_at: Time.current
            )
            plan.add_coauthor(participatory_space.organization)
            plan.save!

            unless proposals.empty?
              linked_proposals = if proposals.length > 2
                                   proposals.slice!(0, 2)
                                 else
                                   proposals
                                 end
              plan.link_resources(linked_proposals, "included_proposals")
            end

            plan
          end

          # Assign taxonomies on top of legacy category/scope
          assign_taxonomies(plan, selected_filters, component)

          if n.positive?
            Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
              user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil
              plan.add_coauthor(author, user_group:)
            end
          end

          Decidim::Plans::Section.where(component:).each do |section|
            next if section.section_type == "field_taxonomy"

            plan.contents.create!(
              body: Decidim::Faker::Localized.paragraph,
              section:,
              user: admin_user
            )
          end

          Decidim::Comments::Seed.comments_for(plan)
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      private

      attr_reader :participatory_space

      def organization
        @organization ||= participatory_space.organization
      end

      def assign_taxonomies(plan, filter_ids, component)
        taxonomy_section = Decidim::Plans::Section.find_by(
          component:,
          section_type: "field_taxonomy"
        )

        selected_taxonomy_ids = []

        Decidim::TaxonomyFilter.where(id: filter_ids).each do |filter|
          taxonomy_ids = filter.filter_items.map(&:taxonomy_item_id)
          next if taxonomy_ids.empty?

          taxonomy_id = taxonomy_ids.sample
          plan.taxonomizations.find_or_create_by(taxonomy_id:)
          selected_taxonomy_ids << taxonomy_id
        end

        # Create the content record for the field_taxonomy section
        if taxonomy_section && selected_taxonomy_ids.any?
          plan.contents.create!(
            section: taxonomy_section,
            body: { taxonomy_ids: selected_taxonomy_ids },
            user: admin_user
          )
        end
      end
    end
  end
end
