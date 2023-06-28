# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AttachmentForm do
  subject do
    described_class.new(
      title: title,
      file: file
    ).with_context(current_organization: organization)
  end

  let(:organization) { create(:organization) }
  let(:title) { "My attachment" }
  let(:file) { Decidim::Dev.test_file("city.jpeg", "image/jpeg") }

  context "with correct data" do
    it "is valid" do
      expect(subject).to be_valid
    end
  end

  context "when the file is present" do
    context "and the title is not present" do
      let(:title) { "" }

      it "is not valid" do
        expect(subject).not_to be_valid
      end
    end
  end

  context "when the file is not present" do
    let(:file) { nil }

    context "and the title is not present" do
      let(:title) { "" }

      it "is not valid" do
        expect(subject).to be_valid
      end
    end
  end

  describe "#to_param" do
    subject { described_class.new(id: id) }

    context "with actual ID" do
      let(:id) { double }

      it "returns the ID" do
        expect(subject.to_param).to be(id)
      end
    end

    context "with nil ID" do
      let(:id) { nil }

      it "returns the ID placeholder" do
        expect(subject.to_param).to eq("attachment-id")
      end
    end

    context "with empty ID" do
      let(:id) { "" }

      it "returns the ID placeholder" do
        expect(subject.to_param).to eq("attachment-id")
      end
    end
  end
end
