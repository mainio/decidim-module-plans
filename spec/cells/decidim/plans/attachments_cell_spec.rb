# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AttachmentsCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/attachments", model) }
  let(:model) { create(:plan) }

  let!(:content) { create(:content, :field_attachments, plan: model, documents:, images:) }
  let(:documents) { create_list(:attachment, 3, :with_pdf, attached_to: model) }
  let(:images) { create_list(:attachment, 3, :with_image, attached_to: model) }

  controller Decidim::Plans::PlansController

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
  end

  context "when rendering" do
    it "renders documents and photos" do
      documents.each do |doc|
        expect(subject).to have_content(translated(doc.title))
      end
      images.each do |img|
        expect(subject).to have_css(%(img[alt="#{translated(img.title)}"]))
      end
    end
  end
end
