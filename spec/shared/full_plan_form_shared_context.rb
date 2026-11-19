# frozen_string_literal: true

require "spec_helper"

shared_context "with full plan form" do
  let(:root_taxonomy) { create(:taxonomy, organization: plan.organization, skip_injection: true) }
  let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization: plan.organization, skip_injection: true) }
  let(:taxonomy_filter) do
    create(
      :taxonomy_filter,
      root_taxonomy:,
      participatory_space_manifests: [plan.participatory_space.manifest.name]
    )
  end

  before do
    plan.component.settings = plan.component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
    plan.component.save!
  end

  let(:section_types) { Decidim::Plans.section_types.all.map(&:name) }
  let(:sections) do
    section_types.map do |type|
      create(:section, type.to_sym, component: plan.component)
    end
  end
  let!(:contents) do
    sections.map do |sect|
      if sect.section_type == "field_taxonomy"
        create(:content, :field_taxonomy, section: sect, plan:, taxonomy:)
      elsif sect.section_type.match(/^(field|link)_/)
        create(:content, sect.section_type.to_sym, section: sect, plan:)
      end
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

shared_context "with full participatory process params" do
  let(:params) do
    {
      component_id: component.id,
      participatory_process_slug: component.participatory_space.slug
    }
  end
end
