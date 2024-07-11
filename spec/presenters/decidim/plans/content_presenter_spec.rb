# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe ContentPresenter do
      subject { described_class.new(content) }
      let(:plan) { create(:plan) }
      let(:content) { create(:content, plan:) }

      let(:malicious_content_array) do
        [
          "<script>alert('XSS');</script>",
          "<img src='https://www.decidim.org'>",
          "<a href='http://www.decidim.org'>Link</a>"
        ]
      end
      let(:malicious_content) { malicious_content_array.join("\n") }

      describe "#title" do
        it "returns title in current locale" do
          expect(subject.title).to eq(content.section.body["en"])
        end

        context "when title contains malicious HTML" do
          let(:section) do
            create(
              :section,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end
          let(:content) { create(:content, section:, plan:) }

          it "sanitizes the HTML" do
            malicious_content_array.each do |mc|
              expect(subject.title).not_to include(mc)
            end
          end
        end
      end

      describe "#body" do
        it "returns body in current locale" do
          expect(subject.body).to eq("<p>#{content.body["en"]}</p>")
        end

        context "when body contains malicious HTML" do
          let(:content) do
            create(
              :content,
              plan:,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end

          it "sanitizes the HTML" do
            malicious_content_array.each do |mc|
              expect(subject.body).not_to include(mc)
            end
          end
        end
      end
    end
  end
end
