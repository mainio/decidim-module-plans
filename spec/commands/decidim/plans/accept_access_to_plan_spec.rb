# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe AcceptAccessToPlan do
      let(:component) { create(:plan_component) }
      let(:state) { :open }
      let(:plan) { create(:plan, state, component:, users: [first_author, second_author]) }
      let(:id) { plan.id }
      let(:requester_user) { create(:user, :confirmed, organization: component.organization) }
      let(:requester_user_id) { requester_user.id }
      let(:first_author) { create(:user, :confirmed, organization: component.organization) }
      let(:second_author) { create(:user, :confirmed, organization: component.organization) }
      let(:current_user) { first_author }
      let(:current_organization) { component.organization }
      let(:form) { AcceptAccessToPlanForm.from_params(form_params).with_context(current_user:, current_organization:) }
      let(:form_params) do
        {
          state:,
          id:,
          requester_user_id:
        }
      end

      describe "Author (current_user) accepts access to requester to collaborate" do
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

          it "adds the requester as a co-author of the plan" do
            command.call
            updated_draft = Plan.find(plan.id)
            expect(updated_draft.authors).to include(requester_user)
          end

          it "notifies the requester and authors of the plan that access to requester has been accepted" do
            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.plans.plan_access_accepted",
                event_class: Decidim::Plans::PlanAccessAcceptedEvent,
                resource: be_an_instance_of(Decidim::Plans::Plan),
                followers: match_array(plan.authors - [requester_user]),
                extra: {
                  requester_id: requester_user_id
                }
              )

            expect(Decidim::EventsManager)
              .to receive(:publish)
              .with(
                event: "decidim.events.plans.plan_access_requester_accepted",
                event_class: Decidim::Plans::PlanAccessRequesterAcceptedEvent,
                resource: plan,
                affected_users: contain_exactly(requester_user)
              )

            command.call
          end
        end

        context "when the plan is withdrawn" do
          let(:state) { :withdrawn }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end

          it "doesn't add the requester as a co-author of the plan" do
            expect do
              command.call
            end.not_to change(plan.authors, :count)
          end
        end

        context "when the plan is published" do
          let(:state) { :published }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end

          it "doesn't add the requester as a co-author of the plan" do
            expect do
              command.call
            end.not_to change(plan.authors, :count)
          end
        end

        context "when the requester is missing" do
          let(:requester_user_id) { nil }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the plan" do
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

          it "doesn't accept the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end

        context "when the requester is not as a requestor" do
          let(:not_requester_user) { create(:user, :confirmed, organization: component.organization) }
          let(:requester_user_id) { not_requester_user.id }

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't accept the request for the plan" do
            expect do
              command.call
            end.not_to change(plan.requesters, :count)
          end
        end
      end
    end
  end
end
