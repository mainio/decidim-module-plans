# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::ApplicationHelper do
  describe "#tabs_id_for_section" do
    let(:section) { double }

    it "returns correct tab id" do
      expect(section).to receive(:to_param).and_return("param")
      expect(helper.tabs_id_for_section(section)).to eq("section_param")
    end
  end

  describe "#tabs_id_for_content" do
    it "returns correct tab id" do
      expect(helper.tabs_id_for_content("test")).to eq("content_test")
    end
  end
end
