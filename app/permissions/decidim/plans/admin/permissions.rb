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
                                      permission_action.subject != :sections &&
                                      permission_action.subject != :plan_tag &&
                                      permission_action.subject != :plan_tags

          case permission_action.action
          when :read, :create, :export_budgets
            permission_action.allow!
          when :edit, :update, :destroy
            permission_action.allow! if plan.present? || section.present? || tag.present?
          when :close, :edit_taggings
            permission_action.allow! if plan.present?
          end

          permission_action
        end

        private

        def plan
          @plan ||= context.fetch(:plan, nil)
        end

        def section
          @section ||= context.fetch(:section, nil)
        end

        def tag
          @tag ||= context.fetch(:tag, nil)
        end

        def admin_plan_answering_is_enabled?
          current_settings.try(:plan_answering_enabled) &&
            component_settings.try(:plan_answering_enabled)
        end
      end
    end
  end
end
