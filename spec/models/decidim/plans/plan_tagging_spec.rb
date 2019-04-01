# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanTagging do
      subject { tagging }

      let(:component) { build :plan_component }
      let(:organization) { component.participatory_space.organization }
      let(:plan) { create(:plan, component: component) }
      let(:tag) { create(:tag, organization: component.organization) }

      let(:tagging) { described_class.new(plan: plan, tag: tag) }

      it { is_expected.to be_valid }

      context "when there is no plan" do
        let(:plan) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when there is no tag" do
        let(:tag) { nil }

        it { is_expected.not_to be_valid }
      end
    end
  end
end
