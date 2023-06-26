# frozen_string_literal: true

module Decidim
  module Plans
    class FlagModalCell < Decidim::ViewModel
      include ActionView::Helpers::FormOptionsHelper

      delegate :current_organization, to: :controller

      private

      def modal_id
        options[:modal_id] || "flagModal"
      end

      def report_form
        @report_form ||= Decidim::ReportForm.new(reason: "spam")
      end
    end
  end
end
