# frozen_string_literal: true

require "spec_helper"

shared_context "with full plan form" do
  let(:section_types) { Decidim::Plans.section_types.all.map(&:name) }
  let(:sections) do
    section_types.map do |type|
      create(:section, type.to_sym, component: plan.component)
    end
  end
  let!(:contents) do
    sections.map do |sect|
      create(:content, sect.section_type.to_sym, section: sect, plan: plan) if sect.section_type.match(/^(field|link)_/)
    end.compact
  end
end
