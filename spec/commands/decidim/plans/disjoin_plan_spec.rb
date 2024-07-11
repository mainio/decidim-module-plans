# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::DisjoinPlan do
  let(:component) { create(:plan_component) }
  let(:first_user) { create(:user, :confirmed, organization: component.organization) }
  let(:second_user) { create(:user, :confirmed, organization: component.organization) }
  let!(:third_user) { create(:user, :confirmed, organization: component.organization) }
  let(:authors) { [first_user, second_user] }
  let(:plan) { create(:plan, component:, users: authors) }
  let(:command) do
    described_class.new(plan, unwanted_author)
  end

  context "when the couthorship does not exist" do
    let(:unwanted_author) { third_user }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when user is an author" do
    let(:unwanted_author) { first_user }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  context "when everything is ok" do
    let!(:authorship) { create(:coauthorship, coauthorable: plan, author: third_user) }
    let(:unwanted_author) { third_user }

    it "broadcasts ok and deletes the coauthorship" do
      expect(command.call).to broadcast(:ok, plan)
      expect(plan_coauthors).not_to include(third_user.id)
    end
  end

  private

  def plan_coauthors
    plan.reload.coauthorships.pluck(:decidim_author_id)
  end
end
