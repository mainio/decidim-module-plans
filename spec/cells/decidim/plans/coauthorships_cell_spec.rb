# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::CoauthorshipsCell, type: :cell do
  subject { my_cell }

  let(:my_cell) { cell("decidim/plans/coauthorships", model) }

  let(:plan) { create(:plan) }
  let(:model) { plan }

  describe "#show" do
    it "renders collapsible author cell" do
      expect(my_cell).to receive(:cell).with(
        "decidim/plans/collapsible_authors",
        any_args
      )
      subject.call
    end

    context "when authorable" do
      let(:model) { plan.coauthorships.first }

      it "renders author cell" do
        expect(my_cell).to receive(:cell).with(
          "decidim/plans/author",
          any_args
        )
        subject.call
      end
    end
  end
end
