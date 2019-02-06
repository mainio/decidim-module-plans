# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::TraceabilityHelper do
  let(:version1) { double }
  let(:version2) { double }
  let(:version3) { double }
  let(:versions) { [version1, version2, version3] }
  let(:renderer1) { double }
  let(:renderer2) { double }
  let(:renderer3) { double }
  let(:renderers) { [renderer1, renderer2, renderer3] }

  def set_expected_redenrers
    allow(helper).to receive(:renderer_for) do |version|
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
      before do
        expect(helper).to receive(:item_versions).and_return(versions)
      end

      it "returns the correct renderers" do
        set_expected_redenrers
        expect(helper.item_diff_renderers).to match_array(renderers)
      end
    end

    context "when actually calling renderer_for" do
      let(:component_settings) { double }
      let(:version) { double }

      before do
        allow(component_settings).to receive(:multilingual_answers?).and_return(true)
        allow(helper).to receive(:component_settings).and_return(component_settings)
        allow(helper).to receive(:item_versions).and_return([version])
      end

      context "with Decidim::Plans::Plan as version.item" do
        before do
          allow(version).to receive(:item).and_return(create(:plan))
        end

        it "returns Decidim::Plans::DiffRenderer::Plan" do
          renderers = helper.item_diff_renderers
          expect(renderers.first).to be_a(Decidim::Plans::DiffRenderer::Plan)
        end
      end

      context "with Decidim::Plans::Content as version.item" do
        before do
          allow(version).to receive(:item).and_return(create(:content))
        end

        it "returns Decidim::Plans::DiffRenderer::Content" do
          renderers = helper.item_diff_renderers
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
          renderers = helper.item_diff_renderers
          expect(renderers.first).to be_a(Decidim::Plans::DiffRenderer::Categorization)
        end
      end
    end
  end

  describe "#associated_diff_renderers" do
    before do
      set_expected_redenrers
      expect(helper).to receive(:associated_versions).and_return(versions)
    end

    it "returns the correct renderers" do
      expect(helper.associated_diff_renderers).to match_array(renderers)
    end
  end

  describe "#content_diff_renderers" do
    before do
      set_expected_redenrers
      expect(helper).to receive(:content_versions).and_return(versions)
    end

    it "returns the correct renderers" do
      expect(helper.content_diff_renderers).to match_array(renderers)
    end
  end

  describe "#diff_renderers" do
    let(:item_diff) { [double, double, double] }
    let(:associated_diff) { [double, double, double] }
    let(:content_diff) { [double, double, double] }

    before do
      expect(helper).to receive(:item_diff_renderers).and_return(item_diff)
      expect(helper).to receive(:associated_diff_renderers).and_return(associated_diff)
      expect(helper).to receive(:content_diff_renderers).and_return(content_diff)
    end

    it "returns the correct renderers" do
      expect(helper.diff_renderers).to match_array(
        item_diff + associated_diff + content_diff
      )
    end
  end

  describe "#render_diff_value" do
    let(:action) { "action" }

    context "when :date type" do
      let(:value) { Time.current }

      it "localizes the value" do
        expect(helper).to receive(:l).with(value, format: :long).and_call_original
        helper.send(:render_diff_value, value, :date, action)
      end
    end

    context "when :percentage type" do
      let(:value) { 10.02 }

      it "localizes the value" do
        expect(helper).to receive(:number_to_percentage).with(value, precision: 2).and_call_original
        helper.send(:render_diff_value, value, :percentage, action)
      end
    end

    context "when :translatable type" do
      let(:value) { double }

      it "localizes the value" do
        expect(value).to receive(:to_s).and_return("Translatable text")
        helper.send(:render_diff_value, value, :translatable, action)
      end
    end

    context "when other type" do
      let(:value) { "Content text" }

      it "localizes the value" do
        output = helper.send(:render_diff_value, value, :other, action)
        expect(output).to have_css("div.diff__value:contains('Content text')")
      end
    end
  end
end
