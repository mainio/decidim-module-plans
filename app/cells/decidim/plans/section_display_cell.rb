# frozen_string_literal: true

module Decidim
  module Plans
    class SectionDisplayCell < Decidim::Plans::SectionCell
      include Decidim::ApplicationHelper
      include Decidim::TranslatableAttributes

      def show
        return if model.blank?
        return if presenter.body.empty?

        render
      end

      private

      def presenter
        @presenter ||= present(model)
      end

      def section
        model.section
      end
    end
  end
end
