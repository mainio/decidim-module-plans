# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::ClosePlan do
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:plan) { create(:plan, component: component, users: [user]) }

  describe "call" do
    context "when called with a user" do
      let(:subject) do
        described_class.new(plan, user)
      end

      context "with unanswered plan" do
        it "broadcasts ok" do
          expect { subject.call }.to broadcast(:ok)
          expect(plan.closed_at).not_to be_nil
          expect(plan.state).to eq("evaluating")
        end
      end

      context "with answered plan" do
        let(:plan) do
          create(
            :plan,
            component: component,
            users: [user],
            state: "accepted",
            answered_at: Time.current
          )
        end

        it "does not change state" do
          expect { subject.call }.not_to change(plan, :state)
        end
      end
    end

    context "when without a user" do
      let(:subject) do
        described_class.new(plan, nil)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
