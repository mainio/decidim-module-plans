# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::UpdatePlan do
  let(:form_klass) { Decidim::Plans::Admin::PlanForm }

  let(:component) { create(:plan_component) }
  let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  let!(:plan) { create :plan, component: component }

  describe "call" do
    let(:proposals) { plan.linked_resources(:proposals, "included_proposals") }

    let(:form_params) do
      {
        title: { en: "A reasonable plan title" },
        proposal_ids: proposals.map(&:id)
      }
    end

    let(:command) do
      described_class.new(form, plan)
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

      context "with updated proposals" do
        let(:proposals) { create_list(:proposal, 3, component: proposal_component) }
        let!(:original_proposals) { plan.linked_resources(:proposals, "included_proposals") }

        it "does not update the linked proposals" do
          command.call
          linked_proposals = plan.linked_resources(:proposals, "included_proposals")
          expect(linked_proposals).to match_array(original_proposals)
        end
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

      it "traces the update", versioning: true do
        expect(Decidim::Plans.loggability)
          .to receive(:update!)
          .with(plan, user, a_kind_of(Hash))
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      it "does not update the plan authors" do
        expect do
          command.call
        end.not_to change(plan, :authors)
      end

      context "with updated proposals" do
        let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

        it "updates the linked proposals" do
          command.call
          linked_proposals = plan.linked_resources(:proposals, "included_proposals")
          expect(linked_proposals).to match_array(proposals)
        end
      end
    end
  end
end
