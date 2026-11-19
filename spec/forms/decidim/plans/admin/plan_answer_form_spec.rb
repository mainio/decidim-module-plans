# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe PlanAnswerForm do
        subject { form }

        let(:organization) { create(:organization, tos_version: Time.current) }
        let(:state) { "accepted" }
        let(:answer) { Decidim::Faker::Localized.sentence(word_count: 3) }
        let(:params) do
          {
            state:, answer:
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_organization: organization
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the state is not valid" do
          let(:state) { "foo" }

          it { is_expected.to be_invalid }
        end

        context "when there's no state" do
          let(:state) { nil }

          it { is_expected.to be_invalid }
        end

        context "when rejecting a plan" do
          let(:state) { "rejected" }

          context "and there's no answer" do
            let(:answer) { nil }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
