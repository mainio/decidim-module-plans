# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Admin::PlansController do
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
        let(:component) { create(:plan_component) }

        before do
          create_list(:plan, 10, :published, component:)
          create_list(:plan, 5, :unpublished, component:)
        end

        it "renders the index listing" do
          get :index, params: params
          expect(response).to have_http_status(:ok)
          expect(controller.send(:counts)).to include(
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
        let(:component) { create(:plan_component) }
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

      describe "POST close" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component:, users: [user]) }

        it "closes the plan" do
          post :close, params: params.merge(id: plan.id)
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).closed?).to be(true)
        end
      end

      describe "POST reopen" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, closed_at: Time.current, component:, users: [user]) }

        it "reopens the plan" do
          post :reopen, params: params.merge(id: plan.id)
          expect(response).to have_http_status(:found)
          expect(Decidim::Plans::Plan.find(plan.id).closed?).to be(false)
        end
      end

      describe "GET edit" do
        let(:component) { create(:plan_component) }
        let(:plan) { create(:plan, component:, users: [user]) }

        it "renders the edit form" do
          get :edit, params: params.merge(id: plan.id)
          expect(response).to have_http_status(:ok)
          expect(subject).to render_template(:edit)
        end
      end

      describe "PATCH update" do
        let(:component) { create(:plan_component) }
        let(:section) { create(:section, :field_text, component:) }
        let(:plan) { create(:plan, component:, users: [user]) }
        let!(:content) { create(:content, :field_text, section:, plan:) }

        context "with valid params" do
          it "updates the plan content" do
            patch :update, params: params.merge(
              id: plan.id,
              contents: [
                {
                  id: content.id,
                  section_id: section.id,
                  body_en: "Updated content body for testing"
                }
              ]
            )

            expect(flash[:notice]).not_to be_empty
            expect(response).to have_http_status(:found)
            expect(translated(content.reload.body)).to eq("Updated content body for testing")
          end
        end

        context "with invalid params" do
          let(:root_taxonomy) { create(:taxonomy, organization: component.organization, skip_injection: true) }
          let(:taxonomy_filter) do
            create(
              :taxonomy_filter,
              root_taxonomy:,
              participatory_space_manifests: [component.participatory_space.manifest.name]
            )
          end
          let(:mandatory_section) { create(:section, :field_taxonomy, component:, mandatory: true) }
          let!(:mandatory_content) do
            create(:content, :field_taxonomy, section: mandatory_section, plan:, taxonomy: create(:taxonomy, parent: root_taxonomy, organization: component.organization, skip_injection: true))
          end

          before do
            component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
            component.save!
          end

          it "renders the edit form again" do
            patch :update, params: params.merge(
              id: plan.id,
              contents: [
                {
                  id: mandatory_content.id,
                  section_id: mandatory_section.id,
                  taxonomy_ids: [""]
                }
              ]
            )

            expect(flash.now[:alert]).not_to be_empty
            expect(subject).to render_template(:edit)
          end
        end
      end
    end
  end
end
