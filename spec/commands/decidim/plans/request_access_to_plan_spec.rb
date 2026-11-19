# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe RequestAccessToPlan do
      let(:component) { create(:plan_component) }
      let(:state) { :open }

      let(:plan) { create(:plan, state, component:, users: [first_author, second_author]) }
      let(:id) { plan.id }
      let(:form) { RequestAccessToPlanForm.from_params(form_params).with_context(current_user:) }
      let(:form_params) do
        {
          state:,
          id:
        }
      end
      let(:current_user) { create(:user, :confirmed, organization: component.organization) }
      let(:first_author) { create(:user, :confirmed, organization: component.organization) }
      let(:second_author) { create(:user, :confirmed, organization: component.organization) }

      describe "User requests to collaborate" do
        let(:command) { described_class.new(form, current_user) }

        context "when the plan is open" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "creates a new request for the plan" do
            expect do
              command.call
            end.to change(plan.requesters, :count).by(1)
          end

          it "notifies all authors of the plan that access has been requested" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.plans.plan_access_requested",
                event_class: Decidim::Plans::PlanAccessRequestedEvent,
                resource: plan,
                followers: plan.authors,
                extra: {
                  requester_id: current_user.id
                }
              )

            command.call
          end
        end

        context "when the plan is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't create a new requestor for the plan" do
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

          it "doesn't create a new requestor for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end
      end
    end
  end
end
