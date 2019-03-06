# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe ContentPresenter do
      let(:subject) { described_class.new(content) }
      let(:plan) { create(:plan) }
      let(:content) { create(:content, plan: plan) }

      describe "#title" do
        it "returns title in current locale" do
          expect(subject.title).to eq(content.section.body["en"])
        end

        context "when title contains malicious HTML" do
          let(:malicious_content) { "<script>alert('XSS');</script>" }
          let(:section) do
            create(
              :section,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end
          let(:content) { create(:content, section: section, plan: plan) }

          it "sanitizes the HTML" do
            expect(subject.title).not_to include(malicious_content)
          end
        end
      end

      describe "#body" do
        it "returns body in current locale" do
          expect(subject.body).to eq("<p>#{content.body["en"]}</p>")
        end

        context "when body contains malicious HTML" do
          let(:malicious_content) { "<script>alert('XSS');</script>" }
          let(:content) do
            create(
              :content,
              plan: plan,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end

          it "sanitizes the HTML" do
            expect(subject.body).not_to include(malicious_content)
          end
        end
      end
    end
  end
end
