# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlansController, type: :controller do
      routes { Decidim::Plans::Engine.routes }

      let(:user) { create(:user, :confirmed, organization: component.organization) }

      let(:params) do
        {
          component_id: component.id
        }
      end

      before do
        request.env["decidim.current_organization"] = component.organization
        request.env["decidim.current_participatory_space"] = component.participatory_space
        request.env["decidim.current_component"] = component
        sign_in user
      end

      describe "GET index" do
        let(:component) { create(:plan_component) }

        it "sorts plans by search defaults" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(assigns(:plans).order_values).to eq(["RANDOM()"])
        end
      end

      describe "GET show" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component) }

        it "shows a single plan" do
          get :show, params: { id: plan.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:show)
        end
      end

      describe "GET new" do
        let(:component) { create(:plan_component, :with_creation_enabled) }

        context "when NO draft plan exist" do
          it "renders the empty form" do
            get :new, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end

        context "when draft plan exist from other users" do
          let!(:others_draft) { create(:plan, :draft, component: component) }

          it "renders the empty form" do
            get :new, params: params
            expect(response).to have_http_status(:ok)
            expect(subject).to render_template(:new)
          end
        end

        context "when draft plan exist from signed in user" do
          let!(:draft) { create(:plan, :draft, component: component, users: [user]) }

          before do
            set_default_url_options
          end

          it "redirects to the draft edit view" do
            get :new, params: params
            expect(response).to have_http_status(:found)
            expect(subject).to redirect_to(edit_plan_path(draft))
          end
        end
      end

      describe "POST create" do
        context "when creation is not enabled" do
          let(:component) { create(:plan_component) }

          it "raises an error" do
            post :create, params: params

            expect(flash[:alert]).not_to be_empty
          end
        end

        context "when creation is enabled" do
          let(:component) { create(:plan_component, :with_creation_enabled) }
          let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }

          it "creates a plan" do
            post :create, params: params.merge(
              title: {
                en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
              },
              proposal_ids: [create(:proposal, component: proposal_component).id]
            )

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end
      end

      describe "GET edit" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, :open, component: component, users: [user]) }

        it "renders the edit view" do
          get :edit, params: { id: plan.id }
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
        end
      end

      describe "PUT update" do
        let(:component) { create(:plan_component) }
        let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:plan) { create(:plan, :open, component: component, users: [user]) }

        it "updates the plan" do
          put :update, params: {
            id: plan.id,
            title: {
              en: "Lorem ipsum dolor sit amet, consectetur adipiscing elit"
            },
            proposal_ids: [create(:proposal, component: proposal_component).id]
          }
          expect(response).to have_http_status(:found)
        end
      end

      describe "DELETE destroy" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, :draft, state: "open", component: component, users: [user]) }

        before do
          set_default_url_options
        end

        it "destroys the plan" do
          plan_to_destroy = plan
          expect do
            delete :destroy, params: { id: plan_to_destroy.id }
            expect(response).to have_http_status(:found)
          end.to change { Decidim::Plans::Plan.count }.by(-1)
        end
      end

      describe "POST publish" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, :draft, state: "open", component: component, users: [user]) }

        before do
          set_default_url_options
        end

        it "publishes the plan" do
          post :publish, params: { id: plan.id }
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).published?).to be(true)
        end
      end

      describe "POST close" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component, users: [user]) }

        before do
          set_default_url_options
        end

        it "closes the plan" do
          post :close, params: { id: plan.id }
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).closed?).to be(true)
        end
      end

      describe "POST reopen" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, closed_at: Time.current, component: component, users: [user]) }

        before do
          set_default_url_options
        end

        it "reopens the plan" do
          post :reopen, params: { id: plan.id }
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).closed?).to be(false)
        end
      end

      describe "withdraw a plan" do
        let(:component) { create(:plan_component, :with_creation_enabled) }

        context "when an authorized user is withdrawing a plan" do
          let(:plan) { create(:plan, component: component, users: [user]) }

          it "withdraws the plan" do
            put :withdraw, params: params.merge(id: plan.id)

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
          end
        end

        describe "when current user is NOT the author of the plan" do
          let(:current_user) { create(:user, organization: component.organization) }
          let(:plan) { create(:plan, component: component, users: [current_user]) }

          context "and the plan has no supports" do
            it "is not able to withdraw the plan" do
              expect(WithdrawPlan).not_to receive(:call)

              put :withdraw, params: params.merge(id: plan.id)

              expect(flash[:alert]).not_to be_empty
              expect(response).to have_http_status(:found)
            end
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
