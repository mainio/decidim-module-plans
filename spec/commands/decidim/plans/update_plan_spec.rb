# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe UpdatePlan do
      let(:form_klass) { PlanForm }

      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:form) do
        form_klass.from_params(
          form_params
        ).with_context(
          current_organization: organization,
          current_participatory_space: component.participatory_space,
          current_component: component
        )
      end

      let!(:plan) { create :plan, component: component, users: [author] }
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
          described_class.new(form, author, plan)
        end

        describe "when the form is not valid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the plan" do
            expect do
              command.call
            end.not_to change(plan, :title)
          end
        end

        describe "when the plan is not editable by the user" do
          before do
            expect(plan).to receive(:editable_by?).and_return(false)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update the plan" do
            expect do
              command.call
            end.not_to change(plan, :title)
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates the plan" do
            expect do
              command.call
            end.to change(plan, :title)
          end

          it "creates a new version for the plan", versioning: true do
            expect do
              command.call
            end.to change { plan.versions.count }.by(1)
            expect(plan.versions.last.whodunnit).to eq author.to_gid.to_s
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
        end
      end
    end
  end
end
