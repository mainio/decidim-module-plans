# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::FlagModalCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/flag_modal", model) }
  let(:model) { create(:plan) }

  controller Decidim::Plans::PlansController

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
    allow(controller).to receive(:current_organization).and_return(model.organization)
  end

  context "when rendering" do
    it "renders the modal" do
      expect(subject).to have_content("Report inappropriate content")
    end
  end
end
