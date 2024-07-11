# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe BudgetsExportsController do
        routes { Decidim::Plans::AdminEngine.routes }

        let(:component) { create(:plan_component) }
        let(:target_component) { create(:budgets_component, participatory_space: component.participatory_space) }
        let(:target_budget) { create(:budget, component: target_component) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let!(:plans) { create_list(:plan, 10, :published, :accepted, closed_at: Time.current, component:) }
        let(:sections) { create_list(:section, 2, :field_text, component:) }

        let(:acceptance) { true }

        let(:sections_param) { sections.map(&:id) }
        let(:params) do
          {
            target_component_id: target_component.try(:id),
            default_budget_amount: 50_000,
            export_all_closed_plans: acceptance,
            content_sections: sections_param,
            target_details: [
              {
                component_id: target_component.try(:id),
                budget_id: target_budget.try(:id)
              }
            ]
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET new" do
          it "renders the export form" do
            get(:new, params:)
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end

        describe "POST create" do
          context "when the command fails" do
            let(:acceptance) { false }

            it "shows an error renders the new template" do
              post(:create, params:)

              expect(flash[:alert]).not_to be_empty
              expect(response).to render_template(:new)
            end
          end

          context "when the content sections has only zero values" do
            let(:sections_param) { [0, 0, 0] }

            it "shows an error renders the new template" do
              post(:create, params:)

              expect(flash[:alert]).not_to be_empty
              expect(response).to render_template(:new)
            end
          end

          context "when the command succeeds" do
            it "creates the plans" do
              expect do
                post(:create, params:)

                expect(flash[:notice]).not_to be_empty
                expect(response).to have_http_status(:found)
              end.to change(Decidim::Budgets::Project, :count).by(10)
            end
          end
        end
      end
    end
  end
end
