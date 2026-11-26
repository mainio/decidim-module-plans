# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class TransferComponent < Decidim::Command
        SECTION_EXCLUDES = %w(id decidim_component_id created_at updated_at position).freeze

        def initialize(form, source_component, user)
          @form = form
          @source = source_component
          @user = user
        end

        def call
          return broadcast(:invalid) if form.invalid?

          transaction do
            copy_sections
            move_plans
            copy_settings
          end

          broadcast(:ok)
        end

        private

        attr_reader :form, :source, :user

        def copy_sections
          form.mapping.each do |source_id, target_id|
            # component scopes it to organization
            # rubocop:disable Decidim/OrganizationScopedFinder
            Section.where(component: target).find(target_id).update!(
              Section.where(component: source).find(source_id).attributes.except(*SECTION_EXCLUDES)
            )
            # rubocop:enable Decidim/OrganizationScopedFinder
          end
        end

        def target
          form.target_component
        end

        def move_plans
          # component scopes it to organization
          # rubocop:disable Decidim/OrganizationScopedFinder
          Plan.where(component: source).find_each do |plan|
            # rubocop:enable Decidim/OrganizationScopedFinder

            move_contents(plan)
            plan.update!(component: target)
            move_taxonomies(plan)
          end
        end

        def move_contents(plan)
          # plan scopes it to organization
          # rubocop:disable Decidim/OrganizationScopedFinder
          Content.where(decidim_plan_id: plan.id).find_each do |content|
            # rubocop:enable Decidim/OrganizationScopedFinder

            new_section_id = form.mapping[content.decidim_section_id]

            if new_section_id
              content.update!(decidim_section_id: new_section_id)
            else
              content.destroy!
            end
          end
        end

        def move_taxonomies(plan)
          return if form.same_space?

          if form.target_taxonomies.none?
            plan.taxonomies = []

            return
          end

          mapped_ids = plan.taxonomies.filter_map { |taxonomy| form.taxonomy_map[taxonomy.id] }
          # plan scopes it to organization
          # rubocop:disable Decidim/OrganizationScopedFinder
          plan.taxonomies = Decidim::Taxonomy.where(id: mapped_ids)
          # rubocop:enable Decidim/OrganizationScopedFinder
        end

        def copy_settings
          target.update!(
            settings: source.settings,
            step_settings: source.participatory_space == target.participatory_space ? source.step_settings : {}
          )
        end
      end
    end
  end
end
