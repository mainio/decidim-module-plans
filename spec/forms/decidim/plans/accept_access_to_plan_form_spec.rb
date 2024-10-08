# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe AcceptAccessToPlanForm do
        subject { form }

        let(:organization) { create(:organization, tos_version: Time.current) }
        let(:plan) { create(:plan, :open) }
        let(:state) { plan.state }
        let(:id) { plan.id }
        let(:current_user) { create(:user, :confirmed, organization:) }
        let(:requester_user) { create(:user, :confirmed, organization:) }
        let(:requester_user_id) { requester_user.id }
        let(:params) do
          {
            state:,
            requester_user_id:,
            id:
          }
        end

        let(:form) do
          described_class.from_params(params)
        end

        before do
          plan.collaborator_requests.create!(user: requester_user)
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

        context "when there's no requester user id" do
          let(:requester_user_id) { nil }

          it { is_expected.to be_invalid }
        end

        context "when the requester user is not a requester" do
          let(:not_requester_user) { create(:user, :confirmed, organization:) }
          let(:requester_user_id) { not_requester_user.id }

          it { is_expected.to be_invalid }
        end
      end
    end
  end
end
