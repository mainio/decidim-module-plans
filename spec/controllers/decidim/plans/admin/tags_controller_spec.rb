# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe TagsController, type: :controller do
        routes { Decidim::Plans::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component, users: [user]) }

        let(:params) do
          {
            plan_id: plan.id
          }
        end

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET index" do
          render_views

          let(:component) { create(:plan_component) }

          before do
            set_default_url_options
            create_list(:tag, 10, organization: component.organization)
          end

          it "renders the index listing" do
            get :index, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
            expect(assigns(:tags).length).to eq(10)
          end
        end

        describe "GET new" do
          it "renders the empty form" do
            get :new, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end

        describe "POST create" do
          before do
            set_default_url_options
          end

          context "when name is empty" do
            let(:params) do
              { plan_id: plan.id, name: { en: "" } }
            end

            it "raises an error" do
              post :create, params: params

              expect(flash[:alert]).not_to be_empty
            end
          end

          context "when name is not empty" do
            let(:params) do
              { plan_id: plan.id, name: { en: "Lorem ipsum dolor" } }
            end

            it "creates a tag" do
              post :create, params: params

              expect(flash[:notice]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end

        describe "GET edit" do
          let(:tag) { create(:tag, organization: component.organization) }

          it "renders the edit view" do
            get :edit, params: { plan_id: plan.id, id: tag.id }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:edit)
          end
        end

        describe "PUT update" do
          let(:tag) { create(:tag, organization: component.organization) }

          before do
            set_default_url_options
          end

          it "updates the tag" do
            put :update, params: {
              plan_id: plan.id,
              id: tag.id,
              name: {
                en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
              }
            }
            expect(response).to have_http_status(:found)
          end
        end

        describe "DELETE destroy" do
          let(:tag) { create(:tag, organization: component.organization) }

          before do
            set_default_url_options
          end

          it "destroys the tag" do
            tag_to_destroy = tag
            expect do
              delete :destroy, params: { plan_id: plan.id, id: tag_to_destroy.id }
              expect(response).to have_http_status(:found)
            end.to change { Decidim::Plans::Tag.count }.by(-1)
          end
        end

        def set_default_url_options
          allow(subject).to receive(:default_url_options).and_return(
            participatory_process_slug: component.participatory_space.slug,
            assembly_slug: component.participatory_space.slug,
            component_id: component.id
          )
        end
      end
    end
  end
end
