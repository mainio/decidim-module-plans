# frozen_string_literal: true

require "spec_helper"

module Decidim::Plans
  describe SectionTypeDisplay::FieldTaxonomyCell, type: :cell do
    controller Decidim::Plans::PlansController

    let(:organization) { create(:organization) }
    let(:component) { create(:plan_component, organization:) }
    let(:plan) { create(:plan, component:) }
    let(:section) { create(:section, :field_taxonomy, component:) }
    let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }

    let(:content) do
      create(:content, section:, plan:, body: { "taxonomy_ids" => taxonomy_ids })
    end

    let(:my_cell) { cell("decidim/plans/section_type_display/field_taxonomy", content) }

    before do
      allow(controller).to receive(:current_organization).and_return(organization)
    end

    context "when the taxonomy still exists" do
      let(:taxonomy_ids) { [taxonomy.id] }

      it "renders the taxonomy name" do
        html = my_cell.call
        expect(html).to have_content(translated(taxonomy.name))
      end
    end

    context "when the taxonomy has been deleted" do
      let(:taxonomy_ids) { [taxonomy.id] }

      before do
        taxonomy.destroy!
      end

      it "does not render anything" do
        html = my_cell.call
        expect(html).to have_no_css(".field-taxonomy-display")
      end

      it "does not raise an error" do
        expect { my_cell.call }.not_to raise_error
      end
    end

    context "when some referenced taxonomies have been deleted and others still exist" do
      let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
      let(:taxonomy_ids) { [taxonomy.id, other_taxonomy.id] }

      before do
        taxonomy.destroy!
      end

      it "renders only the taxonomies that still exist" do
        html = my_cell.call
        expect(html).to have_content(translated(other_taxonomy.name))
        expect(html).to have_no_content(translated(taxonomy.name))
      end
    end

    context "when taxonomy_ids is empty" do
      let(:taxonomy_ids) { [] }

      it "does not render anything" do
        html = my_cell.call
        expect(html).to have_no_css(".field-taxonomy-display")
      end
    end

    context "when taxonomy_ids contains only invalid/zero values" do
      let(:taxonomy_ids) { ["", "0"] }

      it "does not render anything" do
        html = my_cell.call
        expect(html).to have_no_css(".field-taxonomy-display")
      end
    end
  end
end
