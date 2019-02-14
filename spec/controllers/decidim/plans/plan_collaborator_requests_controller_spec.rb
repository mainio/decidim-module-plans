# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanCollaboratorRequestsController, type: :controller do
      routes { Decidim::Plans::Engine.routes }

      let(:component) { create(:plan_component) }
      let(:user) { create(:user, :confirmed, organization: component.organization) }
      let(:plan_creator) { create(:user, :confirmed, organization: component.organization) }
      let(:plan) { create(:plan, :open, component: component, users: [plan_creator]) }
      let(:params) { { id: plan.id, state: "open" } }

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
      end

      describe "POST request_access" do
        context "when user is not signed in" do
          it "raises an error" do
            post :request_access, params: params

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when user is signed in" do
          before do
            sign_in user
          end

          it "creates the request" do
            post :request_access, params: params

            expect(flash[:notice]).not_to be_empty
          end
        end
      end

      describe "POST request_accept" do
        let(:access_params) { params.merge(requester_user_id: user.id) }

        before do
          sign_in plan_creator
        end

        context "when user has not requested for access" do
          it "raises an error" do
            post :request_accept, params: access_params

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when user has requested for access" do
          before do
            plan.collaborator_requests.create!(user: user)
          end

          it "creates the request" do
            post :request_accept, params: access_params

            expect(flash[:notice]).not_to be_empty
          end
        end
      end

      describe "POST request_reject" do
        let(:access_params) { params.merge(requester_user_id: user.id) }

        before do
          sign_in plan_creator
        end

        context "when user has not requested for access" do
          it "raises an error" do
            post :request_reject, params: access_params

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when user has requested for access" do
          before do
            plan.collaborator_requests.create!(user: user)
          end

          it "creates the request" do
            post :request_reject, params: access_params

            expect(flash[:notice]).not_to be_empty
          end
        end
      end
    end
  end
end
