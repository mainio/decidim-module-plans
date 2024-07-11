# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanSerializer do
  subject { described_class.new(plan) }

  let(:component) { create(:plan_component) }
  let(:plan) { create(:plan, component:) }

  before do
    sections = create_list(:section, 3, component:)
    sections.each do |s|
      create(:content, plan:, section: s)
    end
  end

  describe "#serialize" do
    it "serializes the plan to correct format" do
      sectionkeys = plan.sections.map { |s| "section_#{s.id}".to_sym }

      expect(subject.serialize.keys).to include(
        *[
          :id,
          :authors,
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

    it "serializes the plan authors to correct format" do
      expect(subject.serialize[:authors]).to match_array(
        plan.authors.map { |a| "#{a.class}/#{a.id}" }
      )
    end
  end
end
