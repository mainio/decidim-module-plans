# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller allows admins to manage plans in a participatory process.
      class TaggingsController < Admin::ApplicationController
        include Decidim::Tags::Admin::TaggingsController

        before_action do
          enforce_permission_to :edit_taggings, :plan, plan: taggable
        end

        private

        def taggable
          @taggable ||= Plan.where(component: current_component).find(params[:plan_id])
        end

        alias plan taggable
      end
    end
  end
end
