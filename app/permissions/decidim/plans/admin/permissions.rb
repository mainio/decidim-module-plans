# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin

          toggle_allow(admin_plan_answering_is_enabled?) if
            permission_action.action == :create &&
            permission_action.subject == :plan_answer

          return permission_action if permission_action.subject != :plan &&
                                      permission_action.subject != :plans &&
                                      permission_action.subject != :section &&
                                      permission_action.subject != :sections

          case permission_action.action
          when :create
            permission_action.allow!
          when :edit, :update, :destroy
            permission_action.allow! if plan.present? || section.present?
          end

          permission_action
        end

        private

        def plan
          @plan ||= context.fetch(:plan, nil)
        end

        def admin_plan_answering_is_enabled?
          current_settings.try(:plan_answering_enabled) &&
            component_settings.try(:plan_answering_enabled)
        end
      end
    end
  end
end
