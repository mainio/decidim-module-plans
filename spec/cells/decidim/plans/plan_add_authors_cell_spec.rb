# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanAddAuthorsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan_add_authors", model) }
  let(:model) { create(:plan) }

  controller Decidim::Plans::PlansController

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
  end

  context "when rendering" do
    it "renders the modal" do
      expect(subject).to have_content("Add authors for proposal")
    end
  end
end
