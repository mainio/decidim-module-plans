# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

module Decidim
  module Plans
    describe VersionsController, type: :controller do
      routes { Decidim::Plans::Engine.routes }

      with_versioning do
        let(:user) { create(:user, :confirmed, organization: component.organization) }

        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component, users: [user]) }

        before do
          request.env["decidim.current_organization"] = component.organization
          request.env["decidim.current_participatory_space"] = component.participatory_space
          request.env["decidim.current_component"] = component
        end

        describe "GET index" do
          render_views

          before do
            set_default_url_options
          end

          it "sorts plans by search defaults" do
            get :index, params: { plan_id: plan.id }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:index)
          end
        end

        describe "GET show" do
          it "sorts plans by search defaults" do
            get :show, params: { id: 1, plan_id: plan.id }
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:show)
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
