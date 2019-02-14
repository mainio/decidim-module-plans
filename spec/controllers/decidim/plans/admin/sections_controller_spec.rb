# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe SectionsController, type: :controller do
        routes { Decidim::Plans::AdminEngine.routes }

        let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

        let(:component) { create(:plan_component) }

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
            create_list(:section, 10, component: component)
          end

          it "renders the index listing" do
            get :index
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
            expect(assigns(:sections).length).to eq(10)
          end
        end

        describe "POST create" do
          before do
            set_default_url_options
          end

          context "when body is empty" do
            let(:params) do
              {
                sections: [
                  {
                    section_type: Decidim::Plans::Section::TYPES.first,
                    position: 0,
                    body: { en: "" }
                  }
                ]
              }
            end

            it "raises an error" do
              post :create, params: params

              expect(flash[:alert]).not_to be_empty
            end
          end

          context "when body is not empty" do
            let(:params) do
              {
                sections: [
                  {
                    section_type: Decidim::Plans::Section::TYPES.first,
                    position: 0,
                    body: { en: "Lorem ipsum dolor" }
                  }
                ]
              }
            end

            it "creates a plan" do
              post :create, params: params

              expect(flash[:notice]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
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
