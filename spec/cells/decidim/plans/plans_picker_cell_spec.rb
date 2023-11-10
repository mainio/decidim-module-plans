# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlansPickerCell, type: :cell do
  controller Decidim::Plans::PlansController

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plans_picker", component) }
  let(:organization) { create(:organization, tos_version: Time.current) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:plan_component, participatory_space: participatory_space) }
  let!(:plans) { create_list(:plan, 30, :accepted, component: component) }
  let!(:withdrawn_plans) { create_list(:plan, 30, :withdrawn, component: component) }

  let(:another_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:another_component) { create(:plan_component, participatory_space: another_space) }
  let!(:external_plan) { create(:plan, :accepted, component: another_component) }

  it "renders accepted plans" do
    plans.each do |plan|
      expect(subject).to have_content(translated(plan.title))
    end
  end

  it "does not render withdrawn plans" do
    withdrawn_plans.each do |plan|
      expect(subject).not_to have_content(translated(plan.title))
    end
  end

  it "does not render plans from other components" do
    expect(subject).not_to have_content(translated(external_plan.title))
  end
end
