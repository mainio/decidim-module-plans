# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Content do
      subject { content }

      let(:organization) { create(:organization, tos_version: Time.current) }
      let(:user) { create(:user, :confirmed, organization:) }
      let(:participatory_process) { create(:participatory_process, organization:) }
      let(:component) { build(:plan_component) }
      let(:plan) { create(:plan, component:) }
      let(:section) { create(:section, component:) }
      let(:content) { create(:content, plan:, section:, user:) }

      it { is_expected.to be_valid }

      it "has an association of plan" do
        expect(subject.plan).to eq(plan)
      end

      it "has an association of section" do
        expect(subject.section).to eq(section)
      end

      it "has an association of user" do
        expect(subject.user).to eq(user)
      end
    end
  end
end
