# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AttachmentsHelper do
  let(:current_component) { create :plan_component }

  before do
    allow(helper).to receive(:current_component).and_return(current_component)
  end

  describe "#tabs_id_for_attachment" do
    it "returns the correct id" do
      param = "param"
      attachment = double
      allow(attachment).to receive(:to_param).and_return(param)

      expect(helper.tabs_id_for_attachment(attachment)).to eq("attachment_#{param}")
    end
  end

  describe "#blank_attachment" do
    it "returns a Plans::AttachmentForm" do
      expect(helper.blank_attachment).to be_a(Decidim::Plans::AttachmentForm)
    end
  end

  describe "#upload_field" do
    let(:ctx) { ctx_class.new }
    # context.send(:include, ActionView::Helpers::FormHelper)
    # context.send(:include, ActionView::Helpers::UrlHelper)
    let(:ctx_class) do
      Class.new(ActionView::Base) do
        include Decidim::Plans::AttachmentsHelper
      end
    end
    let(:form) { form_class.new(:object, form_object, ctx, {}) }
    let(:form_class) { Class.new(Decidim::FormBuilder) }
    let(:form_object) { double }
    let(:attribute) { :test }
    let(:value) { nil }

    before do
      allow(form_object).to receive(attribute).and_return(value)
      allow(form).to receive(:object).and_return(form_object)
    end

    it "returns a Plans::AttachmentForm" do
      output = ctx.upload_field(form, attribute)
      expect(output).to have_css("label[for='object_test']:contains(Test)")
      expect(output).to have_css("input[type='file'][name='object[test]']")
    end

    context "when image file is set" do
      let(:file) { double }
      let(:url) { "http://url.to/file.jpg" }

      it "links to image file" do
        allow(form_object).to receive(attribute).and_return(file)
        allow(file).to receive(:url).and_return(url)
        allow(form).to receive(:file_is_image?).with(file).and_return(true)
        allow(file).to receive(:present?).and_return(true)

        output = ctx.upload_field(form, attribute)
        expect(output).to have_css("img[src='#{url}']")
      end
    end

    context "when document file is set" do
      let(:file) { double }
      let(:fileobj) { double }
      let(:url) { "http://url.to/file.pdf" }

      it "links to document file" do
        allow(form_object).to receive(attribute).and_return(file)
        allow(file).to receive(:url).and_return(url)
        allow(file).to receive(:file).and_return(fileobj)
        allow(fileobj).to receive(:filename).and_return("file.pdf")
        allow(form).to receive(:file_is_image?).with(file).and_return(false)
        allow(form).to receive(:file_is_present?).with(file).and_return(true)

        output = ctx.upload_field(form, attribute)
        expect(output).to have_css("a[href='#{url}']")
      end
    end
  end
end
