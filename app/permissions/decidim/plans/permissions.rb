# frozen_string_literal: true

module Decidim
  module Plans
    class Permissions < Decidim::DefaultPermissions
      def permissions
        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Plans::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin

        return permission_action if permission_action.scope != :public

        return permission_action if permission_action.subject != :plan

        permission_action
      end

      private

      def plan
        @plan ||= context.fetch(:plan, nil)
      end
    end
  end
end
