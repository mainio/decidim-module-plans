# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe CreatePlan do
      let(:form_klass) { PlanForm }
      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:user) { create :user, :confirmed, organization: organization }
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

      let(:author) { create(:user, organization: organization) }

      let(:user_group) do
        create(:user_group, :verified, organization: organization, users: [author])
      end

      describe "call" do
        let(:form_params) do
          {
            title: { en: "This is the plan title" },
            user_group_id: user_group.try(:id)
          }
        end

        let(:command) do
          described_class.new(form, author)
        end

        describe "when the form is not valid" do
          before do
            allow(form).to receive(:invalid?).and_return(true)
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

          context "with an author" do
            let(:user_group) { nil }

            it "sets the author" do
              command.call
              plan = Decidim::Plans::Plan.last

              expect(plan.coauthorships.count).to eq(1)
              expect(plan.authors.count).to eq(1)
              expect(plan.authors.first).to eq(author)
            end
          end

          context "with a user group" do
            it "sets the user group" do
              command.call
              plan = Decidim::Plans::Plan.last

              expect(plan.coauthorships.count).to eq(1)
              expect(plan.user_groups.count).to eq(1)
              expect(plan.user_groups.first).to eq(user_group)
            end
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
