# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when admin users want to create or edit
    # a plan content field.
    class ContentForm < Decidim::Form
      # include OptionallyTranslatableAttributes
      include Decidim::TranslationsHelper

      mimic :content

      alias component current_component

      # optionally_translatable_attribute :body, String
      attribute :body, Hash
      attribute :section_id, Integer
      attribute :plan_id, Integer

      # TODO: Validate field specific types for the :body attribute
      # optionally_translatable_validate_presence :body, if: :mandatory

      attr_writer :section
      attr_writer :plan

      delegate :mandatory, to: :section

      def section
        @section ||= Decidim::Plans::Section.find(section_id)
      end

      def plan
        @plan ||= Decidim::Plans::Plan.find(plan_id)
      end

      def label
        translated_attribute(section.body)
      end

      def help
        translated_attribute(section.help)
      end

      def information_label
        translated_attribute(section.information_label)
      end

      # Public: Map the correct fields.
      #
      # Returns nothing.
      def map_model(model)
        self.section_id = model.decidim_section_id
        self.section = model.section

        self.plan_id = model.decidim_plan_id
        self.plan = model.plan
      end

      def deleted?
        false
      end
    end
  end
end
