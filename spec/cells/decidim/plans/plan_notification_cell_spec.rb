# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanNotificationCell, type: :cell do
  controller Decidim::Plans::PlansController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan_notification", plan) }
  let(:organization) { create(:organization, tos_version: Time.current) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:plan_component) { create(:plan_component, participatory_space:) }
  let(:plan) { create(:plan, :with_answer, component: plan_component) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }

  before do
    allow(controller).to receive(:current_user).and_return(user)
    allow(controller).to receive(:current_component).and_return(plan_component)
  end

  describe "show" do
    context "when model not answered" do
      let(:plan) { create(:plan, :draft, component: plan_component) }

      it "does not render the show" do
        expect(subject).to have_no_css(".callout__title")
      end
    end

    it "renders the show" do
      expect(subject).to have_css(".callout__title")
      expect(subject).to have_css("svg[role=\"img\"][aria-hidden=\"true\"] use[href*=\"#ri-checkbox-circle-line\"]")
      expect(subject).to have_content("This proposal has been accepted")
      within ".callout__content" do
        expect(subject).to have_content(translated(plan.title))
      end
    end
  end
end
