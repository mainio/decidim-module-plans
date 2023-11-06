# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::DisjoinPlan do
  let(:component) { create(:plan_component) }
  let(:user1) { create(:user, :confirmed, organization: component.organization) }
  let(:user2) { create(:user, :confirmed, organization: component.organization) }
  let!(:user3) { create(:user, :confirmed, organization: component.organization) }
  let(:authors) { [user1, user2] }
  let(:plan) { create(:plan, component: component, users: authors) }
  let(:command) do
    described_class.new(plan, unwanted_author)
  end

  context "when the couthorship does not exist" do
    let(:unwanted_author) { user3 }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when user is an author" do
    let(:unwanted_author) { user1 }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let!(:authorship) { create(:coauthorship, coauthorable: plan, author: user3) }
    let(:unwanted_author) { user3 }

    it "broadcasts ok and deletes the coauthorship" do
      expect(command.call).to broadcast(:ok, plan)
      expect(plan_coauthors).not_to include(user3.id)
    end
  end

  private

  def plan_coauthors
    plan.reload.coauthorships.pluck(:decidim_author_id)
  end
end
