# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      class TransfersController < Admin::ApplicationController
        def new
          enforce_permission_to :transfer, :plans

          @form = form(PlanTransferForm).from_params(params)
        end

        def create
          enforce_permission_to :transfer, :plans

          @form = form(PlanTransferForm).from_params(params)

          TransferComponent.call(@form, current_component, current_user) do
            on(:ok) do
              flash[:notice] = t("transfer.create.success", scope: "decidim.plans.admin")
              redirect_to Decidim::EngineRouter.admin_proxy(current_component).plans_path
            end

            on(:invalid) do
              flash.now[:alert] = @form.errors.full_messages.join(", ") if @form.errors.any?
              render :new, status: :unprocessable_content
            end
          end
        end
      end
    end
  end
end
