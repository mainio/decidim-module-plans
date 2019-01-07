# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to manage plans in a participatory process.
      class SectionsController < Admin::ApplicationController
        include Decidim::ApplicationHelper

        helper Plans::ApplicationHelper

        helper_method :blank_section

        def index
          enforce_permission_to :create, :sections
          @form = form(Admin::PlanSectionsForm).from_model(sections)
        end

        def new
          enforce_permission_to :create, :sections
          # TODO
        end

        def create
          enforce_permission_to :create, :section
          @form = form(Admin::PlanSectionsForm).from_params(params)

          Admin::UpdateSections.call(@form, sections) do
            on(:ok) do
              flash[:notice] = I18n.t("update.success", scope: i18n_flashes_scope)
              redirect_to sections_url
            end

            on(:invalid) do
              flash.now[:alert] = I18n.t("update.invalid", scope: i18n_flashes_scope)
              render template: "index"
            end
          end
        end

        def edit
          enforce_permission_to :edit, :section, section: section
          # TODO
        end

        def update
          enforce_permission_to :edit, :section, section: section
        end

        private

        def i18n_flashes_scope
          "decidim.plans.admin.sections"
        end

        def sections
          @sections ||= Section.where(component: current_component)
        end

        def section
          @section ||= Section.where(component: current_component).find(params[:id])
        end

        def blank_section
          @blank_section ||= Admin::SectionForm.new
        end
      end
    end
  end
end
