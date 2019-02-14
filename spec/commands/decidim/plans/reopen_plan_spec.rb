# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::ReopenPlan do
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:plan) { create(:plan, closed_at: Time.current, component: component, users: [user]) }

  describe "call" do
    context "when called with a user" do
      let(:subject) do
        described_class.new(plan, user)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(plan.closed_at).to be_nil
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
