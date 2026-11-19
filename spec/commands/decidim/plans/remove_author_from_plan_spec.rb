# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::RemoveAuthorFromPlan do
  let(:component) { create(:plan_component) }
  let(:first_user) { create(:user, :confirmed, organization: component.organization) }
  let(:second_user) { create(:user, :confirmed, organization: component.organization) }
  let(:authors) { [first_user, second_user] }
  let(:plan) { create(:plan, component:, users: authors) }
  let(:command) do
    described_class.new(plan, unwanted_user)
  end

  context "when authors are less than 2" do
    let(:authors) { [first_user] }
    let(:unwanted_user) { first_user }

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
    let(:unwanted_user) { second_user }

    it "removes autor and returns ok" do
      expect(command.call).to broadcast(:ok, plan)
      expect(plan.reload.authors).not_to include(second_user)
    end
  end
end
