# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlansPickerCell, type: :cell do
  controller Decidim::Plans::PlansController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plans_picker", component) }
  let(:organization) { create(:organization, tos_version: Time.current) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:plan_component) { create(:plan_component, participatory_space:) }
  let!(:plans) { create_list(:plan, 30, :accepted, component: plan_component) }
  let!(:withdrawn_plans) { create_list(:plan, 30, :withdrawn, component: plan_component) }
  let!(:user) { create(:user, :admin, :confirmed, organization:) }
  let!(:component) { create(:budgets_component, participatory_space:) }

  let(:another_space) { create(:participatory_process, :with_steps, organization:) }
  let(:another_component) { create(:plan_component, participatory_space: another_space) }
  let!(:external_plan) { create(:plan, :accepted, component: another_component) }

  it "renders accepted plans" do
    plans.each do |plan|
      expect(subject).to have_content(translated(plan.title))
    end
  end

  it "does not render withdrawn plans" do
    withdrawn_plans.each do |plan|
      expect(subject).to have_no_content(translated(plan.title))
    end
  end

  it "does not render plans from other components" do
    expect(subject).to have_no_content(translated(external_plan.title))
  end

  context "when filters exist" do
    let(:params) do
      { q: { search_text: translated(plans.first.title) } }
    end

    before do
      allow(controller).to receive(:current_user).and_return(user)
      allow(controller).to receive(:current_organization).and_return(organization)
      allow(controller).to receive(:params).and_return(params)
    end

    it "returns the filtered results" do
      expect(subject).to have_content(translated(plans.first.title))
      expect(subject).to have_no_content(translated(plans.last.title))
    end
  end
end
