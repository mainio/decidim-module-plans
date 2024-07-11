# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

describe Decidim::Plans::DiffCell, type: :cell do
  with_versioning do
    subject { my_cell.call }

    let!(:pt_was_enabled) { PaperTrail.enabled? }
    let(:my_cell) do
      cell(
        "decidim/plans/diff",
        model,
        item_versions:,
        content_versions:
      )
    end
    let(:model) { create(:plan, :published) }
    let(:current_version) { model.versions.last }
    let(:item_versions) do
      Decidim::Plans::PaperTrail::Version.where(
        transaction_id: current_version.transaction_id,
        item_type: "Decidim::Plans::Plan"
      ).order(:created_at)
    end
    let(:content_versions) do
      model.sections.map do |section|
        content = model.contents.find_by(section:)
        next unless content

        content.versions.find_by(
          transaction_id: current_version.transaction_id
        )
      end.compact
    end

    let(:version1) { double }
    let(:version2) { double }
    let(:version3) { double }
    let(:versions) { [version1, version2, version3] }
    let(:renderer1) { double }
    let(:renderer2) { double }
    let(:renderer3) { double }
    let(:renderers) { [renderer1, renderer2, renderer3] }

    def set_expected_renderers
      allow(my_cell).to receive(:renderer_for) do |version|
        if version == version1
          renderer1
        elsif version == version2
          renderer2
        elsif version == version3
          renderer3
        end
      end
    end

    describe "#item_diff_renderers" do
      context "when not calling renderer_for" do
        let(:item_versions) { versions }

        it "returns the correct renderers" do
          set_expected_renderers
          expect(my_cell.item_diff_renderers).to match_array(renderers)
        end
      end

      context "when actually calling renderer_for" do
        let(:component_settings) { double }
        let(:version) { double }
        let(:item_versions) { [version] }

        before do
          allow(component_settings).to receive(:multilingual_answers?).and_return(true)
          allow(my_cell).to receive(:component_settings).and_return(component_settings)
        end

        context "with Decidim::Plans::Plan as version.item" do
          before do
            allow(version).to receive(:item).and_return(create(:plan))
          end

          it "returns Decidim::Plans::DiffRenderer::Plan" do
            renderers = my_cell.item_diff_renderers
            expect(renderers.first).to be_a(Decidim::Plans::DiffRenderer::Plan)
          end
        end

        context "with Decidim::Plans::Content as version.item" do
          before do
            allow(version).to receive(:item).and_return(create(:content))
          end

          it "returns Decidim::Plans::DiffRenderer::Content" do
            renderers = my_cell.item_diff_renderers
            expect(renderers.first).to be_a(Decidim::Plans::DiffRenderer::Content)
          end
        end

        context "with Decidim::Categorization as version.item" do
          before do
            allow(version).to receive(:item).and_return(
              Decidim::Categorization.new
            )
          end

          it "returns Decidim::Plans::DiffRenderer::Categorization" do
            renderers = my_cell.item_diff_renderers
            expect(renderers.first).to be_a(Decidim::Plans::DiffRenderer::Categorization)
          end
        end
      end
    end

    describe "#content_diff_renderers" do
      let(:content_versions) { versions }

      before do
        set_expected_renderers
      end

      it "returns the correct renderers" do
        expect(my_cell.content_diff_renderers).to match_array(renderers)
      end
    end

    describe "#diff_renderers" do
      let(:item_diff) { [double, double, double] }
      let(:content_diff) { [double, double, double] }

      before do
        allow(my_cell).to receive(:item_diff_renderers).and_return(item_diff)
        allow(my_cell).to receive(:content_diff_renderers).and_return(content_diff)
      end

      it "returns the correct renderers" do
        expect(my_cell.diff_renderers).to match_array(
          item_diff + content_diff
        )
      end
    end
  end
end
