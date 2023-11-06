# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::RemoveAuthorFromPlan do
  let(:component) { create(:plan_component) }
  let(:user1) { create(:user, :confirmed, organization: component.organization) }
  let(:user2) { create(:user, :confirmed, organization: component.organization) }
  let(:authors) { [user1, user2] }
  let(:plan) { create(:plan, component: component, users: authors) }
  let(:command) do
    described_class.new(plan, unwanted_user)
  end

  context "when authors are less than 2" do
    let(:authors) { [user1] }
    let(:unwanted_user) { user1 }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when user does does included" do
    let!(:user3) { create(:user, :confirmed, organization: component.organization) }
    let(:unwanted_user) { user3 }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when author is blank" do
    let(:unwanted_user) { nil }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let(:unwanted_user) { user2 }

    it "removes autor and returns ok" do
      expect(command.call).to broadcast(:ok, plan)
      expect(plan.reload.authors).not_to include(user2)
    end
  end
end
