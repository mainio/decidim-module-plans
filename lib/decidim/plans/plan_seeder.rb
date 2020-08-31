# frozen_string_literal: true

require "decidim/faker/localized"

module Decidim
  module Plans
    # This class seeds new plans to the database using faker.
    class PlanSeeder
      def initialize(component:, ideas_component: nil, authors: nil, locale: nil, bbox: nil, area_scope: nil)
        @component = component
        @ideas_component = ideas_component
        @authors = authors
        @locale = locale
        @bbox = bbox
        @area_scope = area_scope
      end

      def seed!(amount: 5)
        raise "Please define a component" unless component

        original_locales = I18n.available_locales
        if locale
          # If the given locale is not in the Faker's available locales, those
          # translations will not be loaded
          I18n.available_locales << locale
          I18n.reload!
        end

        if authors.blank? || authors.is_a?(Integer)
          authors_amount = begin
            if authors.is_a?(Integer)
              authors
            else
              10
            end
          end
          authors_amount = amount if authors_amount > amount

          # Create a dummy authors if they are not provided
          @authors = Array.new(authors_amount) do |i|
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

        amount.times do
          coordinates = dummy_coordinates

          title = ::Faker::Lorem.sentence(2)
          plan = Plan.new(
            component: component,
            title: Decidim::Faker::Localized.localized { title },
            published_at: Time.current
          )
          @authors.sample(rand(1..3)).each do |author|
            plan.add_coauthor(author)
          end
          plan.save!

          plan.sections.each do |section|
            next if section.section_type == "content"

            plan.contents.create!(
              body: dummy_section_body(section),
              section: section
            )

            ideas = ideas_sample
            plan.link_resources(ideas, "included_ideas") if ideas.length > 0
          end

          if ::Faker::Boolean.boolean
            # Add versions to the plan
            rand(1..3).times do
              title = ::Faker::Lorem.sentence(2)
              plan.update!(title: Decidim::Faker::Localized.localized { title })

              plan.contents.each do |content|
                next if content.section.section_type == "content"

                content.update!(body: dummy_section_body(content.section))
              end
            end
          end

          yield plan if block_given?
        end
      ensure
        I18n.available_locales = original_locales
      end

      private

      attr_reader :component, :authors, :locale, :bbox

      def dummy_section_body(section)
        case section.section_type
        when "field_area_scope"
          {
            scope_id: @area_scope.children.sample.id
          }
        when "field_category"
          {
            category_id: component.participatory_space.categories.sample.id
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
        when "field_text", "field_text_multiline"
          value = ::Faker::Lorem.paragraph(3)
          Decidim::Faker::Localized.localized { value }
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
