# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe SectionsController do
        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }
        let(:component) { create(:plan_component) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_component"] = component
          sign_in user
        end

        describe "GET index" do
          render_views

          before do
            create_list(:section, 10, component:)
          end

          it "renders the index listing" do
            get :index, params: {
              component_id: component.id,
              participatory_process_slug: component.participatory_space.slug
            }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
            expect(assigns(:sections).length).to eq(10)
          end
        end

        describe "POST create" do
          context "when body is empty" do
            it "raises an error" do
              post :create, params: {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug,
                sections: [
                  {
                    section_type: Decidim::Plans::Section.types.first,
                    handle: "testing",
                    position: 0,
                    body: { en: "" }
                  }
                ]
              }
              expect(flash[:alert]).not_to be_empty
            end
          end

          context "when body is not empty" do
            it "creates a plan" do
              post :create, params: {
                component_id: component.id,
                participatory_process_slug: component.participatory_space.slug,
                sections: [
                  {
                    section_type: Decidim::Plans::Section.types.first,
                    handle: "testing",
                    position: 0,
                    body: { en: "Lorem ipsum dolor" }
                  }
                ]
              }
              expect(flash[:notice]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
          end
        end
      end
    end
  end
end
