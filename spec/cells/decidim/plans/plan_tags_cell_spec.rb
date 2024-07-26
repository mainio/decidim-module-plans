# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanTagsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan_tags", model, context: { current_component: component }) }
  let(:model) { create(:plan, component:) }
  let(:component) { create(:plan_component, participatory_space:) }
  let(:participatory_space) { create(:participatory_process) }

  let(:category) { create(:category, participatory_space:) }
  let(:area_scope) { create(:scope, organization: participatory_space.organization) }
  let!(:category_content) { create(:content, :field_category, plan: model, category:) }
  let!(:area_scope_content) { create(:content, :field_area_scope, plan: model, scope: area_scope) }

  controller Decidim::Plans::PlansController

  context "when rendering" do
    it "renders the form" do
      puts subject
      expect(subject).to have_link(translated(area_scope.name))
      expect(subject).to have_link(strip_tags translated(category.name))
    end
  end
end
