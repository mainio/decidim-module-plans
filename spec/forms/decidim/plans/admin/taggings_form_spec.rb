# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe TaggingsForm do
        subject do
          described_class.from_params(attributes).with_context(
            current_organization: current_organization
          )
        end

        let(:current_organization) { create(:organization) }

        let(:attributes) do
          {
            tags: tags.collect { |t| t.id }
          }
        end

        context "when there are tags" do
          let(:tags) { create_list(:tag, 10, organization: current_organization) }

          it { is_expected.to be_valid }
        end

        context "when there are no tags" do
          let(:tags) { [] }

          it { is_expected.to be_valid }
        end
      end
    end
  end
end
