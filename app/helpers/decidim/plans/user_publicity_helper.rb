# frozen_string_literal: true

module Decidim
  module Plans
    module UserPublicityHelper
      def user_public?(user = nil)
        user ||= current_user if respond_to?(:current_user)
        user ||= self.user if respond_to?(:user)
        return true unless user
        return true unless user.respond_to?(:public?)

        user.public?
      end
    end
  end
end
