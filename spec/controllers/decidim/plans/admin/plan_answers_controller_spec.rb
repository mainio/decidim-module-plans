# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe PlanAnswersController do
        routes { Decidim::Plans::AdminEngine.routes }

        let(:component) { plan.component }
        let(:plan) { create(:plan) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:params) do
          {
            id: plan.id,
            plan_id: plan.id,
            component_id: component.id,
            participatory_process_slug: component.participatory_space.slug,
            state: "rejected"
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "PUT update" do
          context "when the command fails" do
            it "renders the edit template" do
              put(:update, params:)

              expect(response).to render_template(:edit)
            end
          end
        end
      end
    end
  end
end
