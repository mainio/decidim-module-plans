# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe RequestAccessToPlanForm do
      subject { form }

      let(:organization) { create(:organization) }
      let(:plan) { create(:plan, :open) }
      let(:state) { plan.state }
      let(:id) { plan.id }
      let(:current_user) { create(:user, organization: organization) }
      let(:params) do
        {
          state: state,
          id: id
        }
      end

      let(:form) do
        described_class.from_params(params)
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

      context "when there's no plan id" do
        let(:id) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
