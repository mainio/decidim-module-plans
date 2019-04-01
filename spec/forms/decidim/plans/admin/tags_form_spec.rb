# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe TagForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization) }

        let(:name_english) { "English tag" }

        let(:attributes) do
          {
            name: { "en" => name_english },
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when a section is not valid" do
          let(:name_english) { "" }

          it { is_expected.not_to be_valid }
        end
      end
    end
  end
end
