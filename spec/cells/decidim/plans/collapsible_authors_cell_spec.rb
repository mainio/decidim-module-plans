# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::CollapsibleAuthorsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) do
    cell(
      "decidim/plans/collapsible_authors",
      model,
      has_actions: true
    )
  end
  let(:model) { create(:plan) }

  controller Decidim::Plans::PlansController

  it "renders collapsible list" do
    subject
  end

  context "when actionable" do
    let(:author_cell) { double }

    it "renders the actions" do
      allow(my_cell).to receive(:actionable?).and_return(true)
      allow(my_cell).to receive(:cell)
        .with("decidim/plans/author", any_args)
        .and_return(author_cell)
      expect(author_cell).to receive(:call).with(:date)
      expect(author_cell).to receive(:call).with(:flag)
      expect(author_cell).to receive(:call).with(:withdraw)
      expect(subject).to have_css(".author-data__extra")
    end
  end
end
