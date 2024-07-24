# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanCell, type: :cell do
  controller Decidim::Plans::PlansController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan", model) }
  let!(:user_plan) { create(:plan) }
  let!(:current_user) { create(:user, :confirmed, :confirmed, organization: model.participatory_space.organization) }

  before do
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering a user plan" do
    let(:model) { user_plan }

    it "renders the card" do
      expect(subject).to have_css(".card__info")
    end
  end
end
