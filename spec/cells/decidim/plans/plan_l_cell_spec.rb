# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanLCell, type: :cell do
  controller Decidim::Plans::PlansController

  let(:my_cell) { cell("decidim/plans/plan_l", plan) }
  let(:cell_html) { my_cell.call }
  let(:created_at) { 1.month.ago }
  let(:published_at) { Time.current }
  let!(:plan) { create(:plan, created_at: created_at, published_at: published_at) }
  let(:model) { plan }
  let(:user) { create :user, organization: plan.participatory_space.organization }

  it "renders the class names" do
    expect(my_cell.card_classes).to eq("card--plan muted card--full")
  end
end
