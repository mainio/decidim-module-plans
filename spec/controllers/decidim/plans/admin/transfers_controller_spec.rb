# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe TransfersController do
        let(:component) { create(:plan_component) }
        let(:organization) { component.organization }
        let(:space) { component.participatory_space }
        let(:target) { create(:plan_component, participatory_space: space) }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:route_params) { { participatory_process_slug: space.slug, component_id: component.id } }

        before do
          request.env["decidim.current_organization"] = organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET new" do
          it "renders the form" do
            get :new, params: route_params

            expect(response).to have_http_status(:ok)
          end

          it "shows the mapping step when a target is chosen" do
            get :new, params: route_params.merge(transfer: { target_component_id: target.id })

            expect(response).to have_http_status(:ok)
          end
        end

        describe "POST create" do
          let!(:source_section) { create(:section, component:, section_type: "field_text") }
          let!(:target_section) { create(:section, component: target, section_type: "field_text") }
          let!(:plan) { create(:plan, component:) }

          let(:params) do
            {
              transfer: {
                target_component_id: target.id,
                section_mapping: { source_section.id.to_s => target_section.id.to_s }
              }
            }
          end

          it "moves the plans and redirects" do
            post(:create, params: route_params.merge(params))

            expect(response).to have_http_status(:found)
            expect(plan.reload.decidim_component_id).to eq(target.id)
          end

          it "re-renders the form when the mapping is invalid" do
            post :create, params: route_params.merge(transfer: { target_component_id: target.id, section_mapping: {} })

            expect(response).to have_http_status(:unprocessable_content)
            expect(plan.reload.decidim_component_id).to eq(component.id)
          end
        end

        context "when the user is not an admin" do
          let(:user) { create(:user, :confirmed, organization:) }

          it "does not allow the transfer" do
            post :create, params: route_params.merge(transfer: { target_component_id: target.id })

            expect(response).to have_http_status(:found)
            expect(flash[:alert]).to be_present
          end
        end
      end
    end
  end
end
