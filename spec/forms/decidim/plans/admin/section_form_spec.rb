# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe SectionForm do
        subject do
          described_class.from_params(
            section: attributes
          ).with_context(current_organization:)
        end

        let(:current_organization) { create(:organization, tos_version: Time.current) }
        let!(:position) { 0 }
        let(:handle) { "section_0" }

        let(:deleted) { "false" }
        let(:attributes) do
          {
            handle:,
            body_en: "Body en",
            body_ca: "Body ca",
            body_es: "Body es",
            position:,
            deleted:
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the handle is not present" do
          let!(:handle) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the position is not present" do
          let!(:position) { nil }

          it { is_expected.not_to be_valid }
        end

        context "when the body is missing a locale translation" do
          before do
            attributes[:body_en] = ""
          end

          context "when the section is not deleted" do
            let(:deleted) { "false" }

            it { is_expected.not_to be_valid }
          end

          context "when the section is deleted" do
            let(:deleted) { "true" }

            it { is_expected.to be_valid }
          end
        end

        describe "#to_param" do
          subject { described_class.new(id:) }

          context "with actual ID" do
            let(:id) { double }

            it "returns the ID" do
              expect(subject.to_param).to be(id)
            end
          end

          context "with nil ID" do
            let(:id) { nil }

            it "returns the ID placeholder" do
              expect(subject.to_param).to eq("section-id")
            end
          end

          context "with empty ID" do
            let(:id) { "" }

            it "returns the ID placeholder" do
              expect(subject.to_param).to eq("section-id")
            end
          end
        end
      end
    end
  end
end
