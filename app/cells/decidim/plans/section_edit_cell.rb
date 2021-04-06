# frozen_string_literal: true

module Decidim
  module Plans
    class SectionEditCell < Decidim::Plans::SectionCell
      include Decidim::LayoutHelper # For the icon helper
      include Decidim::Plans::RemainingCharactersHelper

      delegate :info_path, :user_signed_in?, to: :controller

      private

      def form
        context[:form]
      end

      def parent_form
        context[:parent_form]
      end

      def multilingual_answers?
        options[:multilingual_answers]
      end

      def field_options
        {
          id: "plan_section_answer_#{model.section.id}",
          label: false,
          help_text: tooltip_help? ? nil : model.help
        }
      end

      # This is a wrapper method to print out correctly style "plain" labels
      # without the fields. The `field` method does not print out the required
      # notification and the `custom_field` method is a private method.
      # Therefore, this method is necessary for printing out consistent labels
      # when they are controlled separately from the field inputs.
      def plain_label(form, attribute, options = {})
        show_required = options.delete(:show_required)
        show_required = true if show_required.nil?

        text = options.delete(:text) || translated_attribute(section.body)
        text += form.send(:required_for_attribute, attribute) if show_required

        form.label(attribute, text, options)
      end

      def information_label
        @information_label ||= translated_attribute(section.information_label).strip
      end

      def help_text
        @help_text ||= translated_attribute(section.help).strip
      end

      def tooltip_help?
        Decidim::Plans.section_edit_tooltips
      end

      def show_info_link?
        strip_tags(translated_attribute(section.information)).length.positive? &&
          information_label.length.positive?
      end
    end
  end
end
