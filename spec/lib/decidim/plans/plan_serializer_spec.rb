# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanSerializer do
  subject { described_class.new(plan) }

  let(:component) { create(:plan_component) }
  let(:plan) { create(:plan, component: component) }

  before do
    sections = create_list(:section, 3, component: component)
    sections.each do |s|
      create(:content, plan: plan, section: s)
    end
  end

  describe "#serialize" do
    it "serializes the plan to correct format" do
      sectionkeys = plan.sections.map { |s| "section_#{s.id}".to_sym }

      expect(subject.serialize.keys).to include(
        *[
          :id,
          :category,
          :scope,
          :participatory_space,
          :component,
          :state,
          :comments,
          :attachments,
          :followers,
          :published_at,
          :closed_at,
          :url,
          :related_proposals,
          :related_proposals,
          :title
        ].concat(sectionkeys)
      )
    end
  end
end
