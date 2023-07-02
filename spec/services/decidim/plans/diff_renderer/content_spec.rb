# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

module Decidim
  module Plans
    describe DiffRenderer::Content do
      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization: organization) }

      with_versioning do
        subject { described_class.new(version, "en") }

        let(:plan) { create(:plan, component: component) }
        let(:content) { create(:content, plan: plan, body: { en: original_content }) }
        let(:original_content) { "Original content" }
        let(:version) { content.versions.last }

        describe "#diff" do
          let(:updated_content) { "Updated content" }

          before do
            content.update(body: { en: updated_content })
          end

          it "renders correct diff" do
            expect(subject.diff).to include(
              body_en: {
                type: :string,
                label: content.section.body["en"],
                old_value: original_content,
                new_value: updated_content
              }
            )
          end
        end

        describe "#i18n_scope" do
          it "returns expected scope" do
            expect(subject.send(:i18n_scope)).to eq("activemodel.attributes.plan")
          end
        end

        describe "#generate_label" do
          it "returns expected label" do
            expect(subject.send(:generate_label, :any)).to eq(content.section.body["en"])
          end
        end

        describe "#generate_i18n_label" do
          it "returns expected label" do
            allow(subject).to receive(:display_locale).and_return(nil)
            expect(subject.send(:generate_i18n_label, :any, "en")).to eq(
              "#{content.section.body["en"]} (English)"
            )
          end
        end
      end
    end
  end
end
