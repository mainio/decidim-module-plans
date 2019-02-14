# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanActivityCell, type: :cell do
  subject { my_cell }

  let(:my_cell) { cell("decidim/plans/plan_activity", model) }

  let(:plan) { create(:plan) }
  let(:model) do
    create(:action_log, action: "publish", visibility: "all", resource: plan, organization: component.organization, participatory_space: component.participatory_space)
  end
  let(:component) { create(:plan_component) }

  describe "#show" do
    it "renders the activity cell" do
      expect(my_cell).to receive(:title).twice.and_call_original
      expect(my_cell).to receive(:resource_link_text).and_call_original

      subject.call
    end
  end
end
