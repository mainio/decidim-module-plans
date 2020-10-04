# frozen_string_literal: true

module Decidim
  module Plans
    class SectionDisplayCell < Decidim::ViewModel
      include Decidim::Plans::RemainingCharactersHelper

      private

      def form
        context[:form]
      end

      def parent_form
        context[:parent_form]
      end

      def current_component
        context[:current_component]
      end

      def current_locale
        I18n.locale.to_s
      end

      def multilingual_answers?
        options[:multilingual_answers]
      end

      def field_options
        {
          id: "plan_section_answer_#{model.section.id}",
          label: model.label,
          help_text: model.help
        }
      end
    end
  end
end
