# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when admin users want to create or edit
    # a plan content field.
    class ContentForm < Decidim::Form
      include OptionallyTranslatableAttributes
      include Decidim::TranslationsHelper

      # Customized method in order to avoid the translated keys to be saved
      # for all attribute types.
      def self.translatable_attribute(name, type, *options)
        attribute name, Hash, default: {}

        locales.each do |locale|
          attribute_name = "#{name}_#{locale}".gsub("-", "__")
          attribute attribute_name, type, *options

          define_method attribute_name do
            field = public_send(name) || {}
            field[locale.to_s] || field[locale.to_sym]
          end

          define_method "#{attribute_name}=" do |value|
            return unless can_be_translated?

            field = public_send(name) || {}
            public_send("#{name}=", field.merge(locale => super(value)))
          end

          yield(attribute_name, locale) if block_given?
        end
      end

      mimic :content

      alias component current_component

      optionally_translatable_attribute :body, String
      attribute :section_id, Integer
      attribute :plan_id, Integer

      # TODO: Validate field specific types for the :body attribute
      # The translatable body is needed for the text fields in order to store
      # the multilingual values and provide the `body_xx` methods for the form
      # builder which builds the text fields or the editors.
      optionally_translatable_validate_presence :body, if: ->(form) { form.mandatory && form.can_be_translated? }

      attr_writer :section
      attr_writer :plan

      delegate :mandatory, to: :section

      def initialize(attributes = nil)
        # The section definition is already needed when setting the other
        # attributes in order to fetch the section settings.
        self.section_id = attributes[:section_id] if attributes && attributes[:section_id]

        super
      end

      # NOTE: Even when the field is not configured to be translated, the data
      # still needs to be stored in translated format in order to allow enabling
      # multilingual answers afterwards. Therefore, we are listing here all the
      # fields types that SUPPORT multilingual answers.
      def can_be_translated?
        %w(field_text field_text_multiline).include?(section.section_type)
      end

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
