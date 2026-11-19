# frozen_string_literal: true

module Decidim
  module Plans
    class FormBuilder < Decidim::FormBuilder
      private

      # Customized to support custom abide error text via :abide_error option.
      def field_with_validations(attribute, options, html_options)
        class_options = html_options || options

        if error?(attribute)
          class_options[:class] = class_options[:class].to_s
          class_options[:class] += " is-invalid-input"
        end

        help_text = options.delete(:help_text)
        abide_error = options.delete(:abide_error)

        class_options = extract_validations(attribute, options).merge(class_options)

        content = yield(class_options)
        content += abide_error_element(attribute, abide_error) if class_options[:pattern] || class_options[:required]
        content = content.html_safe

        html = error_and_help_text(attribute, options.merge(help_text:))
        html + content
      end

      def abide_error_element(attribute, abide_error = nil)
        return super(attribute) if abide_error.blank?

        content_tag(:span, abide_error, class: "form-error")
      end
    end
  end
end
