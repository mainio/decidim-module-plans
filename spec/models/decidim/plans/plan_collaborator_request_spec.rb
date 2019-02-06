# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanCollaboratorRequest do
      subject { request }

      let(:request) { build(:plan_collaborator_request, plan: plan, user: user) }
      let(:plan) { create(:plan) }
      let(:user) { create(:user) }

      it { is_expected.to be_valid }

      context "when no plan is attached" do
        let(:plan) { nil }

        it { is_expected.to be_invalid }
      end

      context "when no user is attached" do
        let(:user) { nil }

        it { is_expected.to be_invalid }
      end
    end
  end
end
