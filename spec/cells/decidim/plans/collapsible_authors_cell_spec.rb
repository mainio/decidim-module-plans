# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::CollapsibleAuthorsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) do
    cell(
      "decidim/plans/collapsible_authors",
      authors_presenters
    )
  end
  let(:model) { create(:plan) }
  let(:authors_presenters) { model.authors.map { |author| Decidim::UserPresenter.new(author) } }

  controller Decidim::Plans::PlansController

  it "renders collapsible list" do
    expect(subject).to have_css(".author > .author__container")
  end
end
