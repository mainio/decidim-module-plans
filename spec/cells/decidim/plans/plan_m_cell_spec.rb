# frozen_string_literal: true

require "spec_helper"

module Decidim::Plans
  describe PlanMCell, type: :cell do
    controller Decidim::Plans::PlansController

    subject { cell_html }

    let(:my_cell) { cell("decidim/plans/plan_m", plan, context: { show_space: }) }
    let(:cell_html) { my_cell.call }
    let(:created_at) { 1.month.ago }
    let(:published_at) { Time.current }
    let!(:plan) { create(:plan, created_at:, published_at:) }
    let(:model) { plan }
    let(:user) { create(:user, organization: plan.participatory_space.organization) }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    it_behaves_like "has space in m-cell"

    context "when rendering" do
      let(:show_space) { false }

      it "renders the card" do
        expect(subject).to have_css(".card--plan")
      end

      it "renders the published_at date" do
        published_date = I18n.l(published_at.to_date, format: :decidim_short)
        creation_date = I18n.l(created_at.to_date, format: :decidim_short)
        expect(subject).to have_css(".card__info__item", text: published_date)
        expect(subject).to have_no_css(".creation_date_status", text: creation_date)
      end

      context "and is a plan" do
        it "renders the plan state (nil by default)" do
          expect(subject).to have_css(".muted")
          expect(subject).to have_no_css(".card__text--status")
        end
      end
    end
  end
end
