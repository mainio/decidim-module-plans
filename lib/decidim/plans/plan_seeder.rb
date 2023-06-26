# frozen_string_literal: true

require "decidim/faker/localized"

module Decidim
  module Plans
    # This class seeds new plans to the database using faker.
    #
    # Usage:
    #   require "decidim/plans/plan_seeder"
    #   c = Decidim::Component.find(y) # fetch the plans component
    #   ic = Decidim::Component.find(x) # fetch the ideas component (if needed)
    #   as = Decidim::Scope.find(z) # fetch the area scope parent (if needed)
    #   s = Decidim::Scope.find(a) # fetch the scope parent (if needed)
    #   seeder = Decidim::Plans::PlanSeeder.new(
    #              component: c,
    #              ideas_component: ic,
    #              scope: s,
    #              area_scope: as,
    #              locale: "fi",
    #              bbox: [[60.150050, 24.842148], [60.216626, 25.160408]]
    #            )
    #   seeder.seed!(amount: 10)
    class PlanSeeder
      # rubocop:disable Metrics/ParameterLists
      def initialize(
        component:,
        ideas_component: nil,
        authors: nil,
        locale: nil,
        bbox: nil,
        area_scope: nil,
        scope: nil,
        images: nil,
        attachments: nil
      )
        @component = component
        @ideas_component = ideas_component
        @authors = authors
        @locale = locale
        @bbox = bbox
        @area_scope = area_scope
        @scope = scope
        @images = images
        @attachments = attachments
      end
      # rubocop:enable Metrics/ParameterLists

      def seed!(amount: 5)
        raise "Please define a component" unless component

        original_locales = I18n.available_locales
        if locale
          # If the given locale is not in the Faker's available locales, those
          # translations will not be loaded
          I18n.available_locales << locale
          I18n.reload!
        end

        ensure_authors!(max_amount: amount)

        amount.times do
          plan = generate_plan

          yield plan if block_given?
        end
      ensure
        I18n.available_locales = original_locales
      end

      def seed_attachments!
        raise "Please define a component" unless component
        raise "No images or attachments provided" if images.blank? && attachments.blank?

        Plan.where(component: component).each do |plan|
          # No need to seed when the plan already has attachments
          next if plan.attachments.count.positive?

          seed_plan_images_and_attachments!(plan)
        end
      end

      private

      attr_reader :component, :authors, :locale, :bbox, :images, :attachments

      def ensure_authors!(max_amount: 5)
        return if authors.present? && !authors.is_a?(Integer)

        authors_amount = begin
          if authors.is_a?(Integer)
            authors
          else
            10
          end
        end
        authors_amount = max_amount if authors_amount > max_amount

        # Create a dummy authors if they are not provided
        @authors = generate_authors(authors_amount)
      end

      def generate_authors(authors_amount)
        Array.new(authors_amount) do |_i|
          author = Decidim::User.find_or_initialize_by(
            email: ::Faker::Internet.email
          )
          author.update!(
            password: "password1234",
            password_confirmation: "password1234",
            name: ::Faker::Name.name,
            nickname: ::Faker::Twitter.unique.screen_name,
            organization: component.organization,
            tos_agreement: "1",
            confirmed_at: Time.current
          )
          author
        end
      end

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def generate_plan
        title = ::Faker::Lorem.sentence(word_count: 2)
        plan = Plan.new(
          component: component,
          title: Decidim::Faker::Localized.localized { title },
          published_at: Time.current
        )
        authors.sample(rand(1..3)).each do |author|
          plan.add_coauthor(author)
        end
        plan.save!

        attachments_weight = 0

        plan.sections.each do |section|
          next if section.section_type == "content"

          body = begin
            case section.section_type
            when "field_image_attachments"
              if should_add_images?
                attachment_ids = create_attachments_from(images.sample(1), plan, attachments_weight)
                attachments_weight += attachment_ids.length
                { "attachment_ids" => attachment_ids }
              else
                { "attachment_ids" => [] }
              end
            when "field_attachments"
              if should_add_attachments?
                attachment_ids = create_attachments_from(attachments.sample(rand(1..3)), plan, attachments_weight)
                attachments_weight += attachment_ids.length
                { "attachment_ids" => attachment_ids }
              else
                { "attachment_ids" => [] }
              end
            else
              dummy_section_body(section)
            end
          end

          plan.contents.create!(
            body: body,
            section: section
          )

          ideas = ideas_sample
          plan.link_resources(ideas, "included_ideas") if ideas.length.positive?
        end

        # Decide randomly whether we want to create plan versions
        return plan if ::Faker::Boolean.boolean

        # Add versions to the plan
        rand(1..3).times do
          title = ::Faker::Lorem.sentence(word_count: 2)
          plan.update!(title: Decidim::Faker::Localized.localized { title })

          plan.contents.each do |content|
            next if %w(content field_attachments field_image_attachments).include?(content.section.section_type)

            content.update!(body: dummy_section_body(content.section))
          end
        end

        plan
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      # rubocop:disable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity
      def seed_plan_images_and_attachments!(plan)
        # Decide whether to add image and/or attachments
        add_image = should_add_images?
        add_attachments = should_add_attachments?
        return if !add_image && !add_attachments

        weight = 0

        plan.sections.each do |section|
          next unless %w(field_attachments field_image_attachments).include?(section.section_type)

          content = plan.contents.find_by(section: section)
          content ||= plan.contents.create!(
            body: { "attachment_ids" => [] },
            section: section
          )

          if add_image && section.section_type == "field_image_attachments"
            attachment_ids = create_attachments_from(images.sample(1), plan, weight)
            content.update!(body: { "attachment_ids" => attachment_ids })
            weight += attachment_ids.length
          elsif add_attachments && section.section_type == "field_attachments"
            attachment_ids = create_attachments_from(attachments.sample(rand(1..3)), plan, weight)
            content.update!(body: { "attachment_ids" => attachment_ids })
            weight += attachment_ids.length
          end
        end
      end
      # rubocop:enable Metrics/CyclomaticComplexity, Metrics/PerceivedComplexity

      def should_add_images?
        images.present? && ::Faker::Boolean.boolean
      end

      def should_add_attachments?
        attachments.present? && ::Faker::Boolean.boolean
      end

      def dummy_section_body(section)
        case section.section_type
        when "field_area_scope"
          {
            scope_id: area_scope_sample_id
          }
        when "field_scope"
          {
            scope_id: scope_sample_id
          }
        when "field_category"
          {
            category_id: category_sample_id
          }
        when "field_checkbox"
          {
            checked: true
          }
        when "field_map_point"
          coords = dummy_coordinates
          {
            address: dummy_address,
            latitude: coords[0],
            longitude: coords[1]
          }
        when "field_number"
          {
            value: ::Faker::Number.number(digits: rand(5..8).to_i)
          }
        when "field_text", "field_text_multiline"
          value = ::Faker::Lorem.paragraph(word_count: 3)
          Decidim::Faker::Localized.localized { value }
        end
      end

      def area_scope_sample_id
        return if @area_scope.blank?

        @area_scope.children.sample.id
      end

      def scope_sample_id
        return if @scope.blank?

        @scope.children.sample.id
      end

      def category_sample_id
        component.participatory_space.categories.sample.id
      end

      def create_attachments_from(files, plan, start_weight = 0)
        weight = start_weight
        files.map do |file|
          attachment = plan.attachments.create!(
            weight: weight,
            title: ::Faker::Lorem.sentence(word_count: rand(3..6)),
            file: file
          )
          weight += 1

          attachment.id
        end
      end

      def ideas_sample
        return [] unless @ideas_component
        return [] unless defined?(Decidim::Ideas::Idea)

        Decidim::Ideas::Idea.where(
          component: @ideas_component
        ).published.order("RANDOM()").limit(rand(1..2))
      end

      def dummy_address
        fake_with_locale do
          # With some locales Faker::Address.street_address returns addresses
          # where there is no space between the street name and building number
          "#{::Faker::Address.street_name} #{::Faker::Address.building_number}"
        end
      end

      def dummy_coordinates
        if bbox
          [rand(bbox[0][0]...bbox[1][0]), rand(bbox[0][1]...bbox[1][1])]
        else
          [::Faker::Address.latitude, ::Faker::Address.longitude]
        end
      end

      def fake_with_locale
        if locale
          ::Faker::Address.with_locale(locale) { yield }
        else
          yield
        end
      end
    end
  end
end
