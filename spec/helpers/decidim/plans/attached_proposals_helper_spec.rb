# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AttachedProposalsHelper do
  let(:form) { double }
  let(:current_component) { create :plan_component }
  let(:search_proposals_path) { "/search_proposals" }

  before do
    allow(helper).to receive(:current_component).and_return(current_component)
    allow(helper).to receive(:plan_search_proposals_path).and_return(search_proposals_path)
  end

  describe "#attached_proposals_picker_field" do
    it "calls the form helper's data_picker method" do
      name = "pick_proposals"

      expect(form).to receive(:data_picker).with(
        name,
        {
          id: "attached_proposals",
          "class": "picker-multiple",
          name: "proposal_ids",
          multiple: true
        },
        url: search_proposals_path,
        text: "Attach proposal"
      )
      helper.attached_proposals_picker_field(form, name)
    end
  end

  describe "#search_proposals" do
    let(:format) { double }

    it "calls the " do
      expect(format).to receive(:html).and_yield
      expect(format).to receive(:json).and_yield
      expect(helper).to receive(:respond_to).and_yield(format)

      # html
      expect(helper).to receive(:render).with(
        hash_including(
          partial: "decidim/plans/attached_proposals/proposals"
        )
      )
      # json
      expect(helper).to receive(:render).with(
        hash_including(
          json: []
        )
      )

      helper.search_proposals
    end
  end
end
