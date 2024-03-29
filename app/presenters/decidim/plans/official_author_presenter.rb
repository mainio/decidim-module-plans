# frozen_string_literal: true

module Decidim
  module Plans
    #
    # A dummy presenter to abstract out the author of an official plan.
    #
    class OfficialAuthorPresenter
      def name
        I18n.t("decidim.plans.models.plan.fields.official_plan")
      end

      def nickname
        ""
      end

      def badge
        ""
      end

      def profile_path
        ""
      end

      def avatar_url(_variant = nil)
        ActionController::Base.helpers.asset_pack_path("media/images/default-avatar.svg")
      end

      def deleted?
        false
      end

      def can_be_contacted?
        false
      end

      def has_tooltip?
        false
      end
    end
  end
end
