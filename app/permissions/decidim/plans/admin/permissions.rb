# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class Permissions < Decidim::DefaultPermissions
        def permissions
          return permission_action unless user

          return permission_action if permission_action.scope != :admin
          return permission_action if permission_action.subject != :plan &&
                                      permission_action.subject != :plans &&
                                      permission_action.subject != :section &&
                                      permission_action.subject != :sections

          case permission_action.action
          when :create
            permission_action.allow!
          when :update, :destroy
            permission_action.allow! if plan.present? || section.present?
          end

          permission_action
        end

        private

        def plan
          @plan ||= context.fetch(:plan, nil)
        end
      end
    end
  end
end
