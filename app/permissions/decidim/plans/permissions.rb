# frozen_string_literal: true

module Decidim
  module Plans
    class Permissions < Decidim::DefaultPermissions
      def permissions
        return permission_action unless user

        # Delegate the admin permission checks to the admin permissions class
        return Decidim::Plans::Admin::Permissions.new(user, permission_action, context).permissions if permission_action.scope == :admin
        return permission_action if permission_action.scope != :public

        if permission_action.subject == :plan
          apply_plan_permissions(permission_action)
        else
          permission_action
        end

        permission_action
      end

      private

      def plan
        @plan ||= context.fetch(:plan, nil)
      end

      def apply_plan_permissions(permission_action)
        case permission_action.action
        when :create
          can_create_plan?
        when :edit
          can_edit_plan?
        when :withdraw
          can_withdraw_plan?
        when :publish
          can_publish_plan?
        when :close
          can_close_plan?
        when :request_access
          can_request_access_plan?
        end
      end

      def can_create_plan?
        toggle_allow(authorized?(:create) && current_settings&.creation_enabled?)
      end

      def can_edit_plan?
        toggle_allow(plan.open? && plan.editable_by?(user))
      end

      def can_withdraw_plan?
        toggle_allow(plan && plan.withdrawable_by?(user))
      end

      def can_publish_plan?
        toggle_allow(plan.open? && plan.editable_by?(user))
      end

      def can_close_plan?
        return toggle_allow(false) unless component_settings.closing_allowed?

        toggle_allow(plan && plan.created_by?(user))
      end

      def can_request_access_plan?
        return toggle_allow(false) unless plan.open?
        return toggle_allow(false) if plan.editable_by?(user)
        return toggle_allow(false) if plan.requesters.include? user

        toggle_allow(plan && !plan.editable_by?(user))
      end
    end
  end
end
