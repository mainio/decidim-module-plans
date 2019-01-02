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
          @form = form(Admin::PlanSectionsForm).from_params({})
        end

        def new
          enforce_permission_to :create, :sections
          # TODO
        end

        def create
          enforce_permission_to :create, :section
          # TODO
        end

        def edit
          enforce_permission_to :edit, :section, section: section
          # TODO
        end

        def update
          enforce_permission_to :edit, :section, section: section
        end

        private

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
