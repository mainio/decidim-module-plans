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
      create(:content, sect.section_type.to_sym, section: sect, plan:) if sect.section_type.match(/^(field|link)_/)
    end.compact
  end
end

shared_context "with plan author params" do
  let(:plan_id) { plan.id }
  let(:slug) { component.participatory_space.slug }
  let(:recipient_id) { [user.id] }
  let(:params) do
    {
      plan_id:,
      recipient_id:,
      component_id: component.id,
      participatory_process_slug: slug
    }
  end
end
