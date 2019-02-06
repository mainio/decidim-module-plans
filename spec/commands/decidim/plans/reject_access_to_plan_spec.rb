# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe RejectAccessToPlan do
      let(:component) { create(:plan_component) }
      let(:state) { :open }
      let(:plan) { create(:plan, state, component: component, users: [author1, author2]) }
      let(:id) { plan.id }
      let(:requester_user) { create(:user, :confirmed, organization: component.organization) }
      let(:requester_user_id) { requester_user.id }
      let(:author1) { create(:user, :confirmed, organization: component.organization) }
      let(:author2) { create(:user, :confirmed, organization: component.organization) }
      let(:current_user) { author1 }
      let(:current_organization) { component.organization }
      let(:form) { RejectAccessToPlanForm.from_params(form_params).with_context(current_user: current_user, current_organization: current_organization) }
      let(:form_params) do
        {
          state: state,
          id: id,
          requester_user_id: requester_user_id
        }
      end

      describe "Author (current_user) rejects access to requester to collaborate" do
        let(:command) { described_class.new(form, current_user) }

        before do
          plan.collaborator_requests.create!(user: requester_user)
        end

        context "when the plan is open" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "removes the requester from requestors of the plan" do
            expect do
              command.call
            end.to change(plan.requesters, :count).by(-1)
          end

          it "notifies the requester and authors of the plan that access to requester has been rejected" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.plans.plan_access_rejected",
                event_class: Decidim::Plans::PlanAccessRejectedEvent,
                resource: plan,
                followers: plan.authors,
                extra: {
                  requester_id: requester_user_id
                }
              )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.plans.plan_access_requester_rejected",
                event_class: Decidim::Plans::PlanAccessRequesterRejectedEvent,
                resource: plan,
                affected_users: [requester_user]
              )

            command.call
          end
        end

        context "when the plan is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end

        context "when the plan is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end

        context "when the requester is missing" do
          let(:requester_user_id) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end

        context "when the current_user is missing" do
          let(:current_user) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end

        context "when the requester is not as a requestor" do
          let(:not_requester) { create(:user, :confirmed, organization: component.organization) }
          let(:requester_user_id) { not_requester.id }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't reject the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end
      end
    end
  end
end
