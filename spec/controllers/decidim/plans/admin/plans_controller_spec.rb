# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Admin::PlansController, type: :controller do
      routes { Decidim::Plans::AdminEngine.routes }

      let(:user) { create(:user, :confirmed, :admin, organization: component.organization) }

      let(:params) do
        {
          component_id: component.id,
          participatory_process_slug: component.participatory_space.slug
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
          create_list(:plan, 10, :published, component: component)
          create_list(:plan, 5, :unpublished, component: component)
        end

        it "renders the index listing" do
          get :index
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:index)
          expect(assigns(:plans).length).to eq(10)
          expect(assigns(:counts)).to include(
            published: 10,
            drafts: 5
          )
        end
      end

      describe "GET new" do
        let(:component) { create(:plan_component, :with_creation_enabled) }

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

      describe "GET taggings" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component, users: [user]) }

        it "renders the taggings list" do
          get :taggings, params: params.merge(id: plan.id)
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:taggings)
        end
      end

      describe "PATCH update_taggings" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component: component, users: [user]) }
        let(:tags) { create_list(:tag, 5, organization: component.organization) }

        before do
          set_default_url_options
        end

        it "updates the taggings" do
          patch :update_taggings, params: params.merge(
            id: plan.id,
            tags: tags.collect { |t| t.id }
          )
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).tags).to eq(tags)
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
