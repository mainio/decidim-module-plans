# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe PlanSectionsForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization, tos_version: Time.current) }

        let(:body_english) { "First section" }

        let(:attributes) do
          {
            "sections" => [
              {
                handle: "section_0",
                body: { "en" => body_english },
                position: 0
              },
              {
                handle: "section_1",
                body: { "en" => "Second section" },
                position: 1
              }
            ]
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when a section is not valid" do
          let(:body_english) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
