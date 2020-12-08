# frozen_string_literal: true

module Decidim
  module Plans
    class PlanIndexCell < Decidim::ViewModel
      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
