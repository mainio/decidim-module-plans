# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe AuthorsController, type: :controller do
        routes { Decidim::Plans::AdminEngine.routes }

        let(:component) { create(:plan_component) }
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:plan) { create(:plan, component: component, users: [user]) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "index" do
          it "renders index" do
            get :index, params: { plan_id: plan.id }
            expect(subject).to render_template(:index)
            expect(response).to have_http_status(:ok)
          end
        end

        describe "create" do
          include_context "with plan author params"

          context "when authors exist" do
            it "responds :ok" do
              put :create, params: params
              expect(subject).to be_an_instance_of(AuthorsController)
            end
          end

          context "with non-existing author" do
            let(:recipient_id) { [123_456] }

            it "gives error and redirects the user" do
              put :create, params: params
              expect(flash[:alert]).to be_present
              expect(subject).to redirect_to("/plans/#{plan_id}/authors")
            end
          end
        end

        describe "confirm" do
          include_context "with plan author params"

          it "adds author and redirects" do
            patch :confirm, params: params

            expect(flash[:success]).to be_present
            expect(subject).to redirect_to("/plans/#{plan_id}/authors")
            expect(plan.authors).to include(user)
          end

          context "when author not exist" do
            let(:recipient_id) { [123_456] }

            it "gives error and redirects" do
              patch :confirm, params: params

              expect(flash[:alert]).to be_present
              expect(subject).to redirect_to("/plans/#{plan_id}/authors")
            end
          end
        end

        describe "destroy" do
          context "with user base entity" do
            let!(:user2) { create(:user, :confirmed, :admin, organization: component.organization) }
            let(:plan) { create(:plan, component: component, users: [user, user2]) }
            let(:slug) { component.participatory_space.slug }
            let(:user_id) { user2.id }
            let(:params) do
              {
                plan_id: plan.id,
                id: user_id,
                component_id: component.id,
                participatory_process_slug: slug
              }
            end

            it "deletes the user and redirects" do
              delete :destroy, params: params
              expect(flash[:success]).to be_present
              expect(subject).to redirect_to("/plans/#{plan.id}/authors")
              expect(plan.reload.authors).not_to include(user2)
            end

            context "when user not exist" do
              let(:plan) { create(:plan, component: component, users: [user2]) }

              it "renders error and redirects" do
                delete :destroy, params: params
                expect(flash[:alert]).to be_present
                expect(subject).to redirect_to("/plans/#{plan.id}/authors")
                expect(plan.reload.authors).to include(user2)
              end
            end
          end
        end
      end
    end
  end
end
