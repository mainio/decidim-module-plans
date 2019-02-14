# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanWidgetsController, type: :controller do
      routes { Decidim::Plans::Engine.routes }

      let(:component) { create(:plan_component) }
      let(:plan) { create(:plan, component: component) }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "GET show" do
        it "sorts plans by search defaults" do
          get :show, params: { plan_id: plan.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:show)
        end
      end
    end
  end
end
