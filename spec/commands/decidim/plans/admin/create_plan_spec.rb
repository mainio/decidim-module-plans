# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe CreatePlan do
        let(:form_klass) { PlanForm }
        let(:component) { create(:plan_component) }
        let(:organization) { component.organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization,
            current_participatory_space: component.participatory_space,
            current_component: component
          )
        end
        let(:attachment_params) { nil }

        describe "call" do
          let(:form_params) do
            {
              user_group_id: nil
            }
          end

          let(:command) do
            described_class.new(form)
          end

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create a plan" do
              expect do
                command.call
              end.not_to change(Decidim::Plans::Plan, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new plan" do
              expect do
                command.call
              end.to change(Decidim::Plans::Plan, :count).by(1)
            end

            it "sets the organization as author" do
              command.call

              expect(Decidim::Plans::Plan.last.authors).to include(organization)
            end

            it "traces the action", versioning: true do
              expect(Decidim::Plans.loggability)
                .to receive(:perform_action!)
                .with(:create, Decidim::Plans::Plan, kind_of(Decidim::User))
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end
          end
        end
      end
    end
  end
end
