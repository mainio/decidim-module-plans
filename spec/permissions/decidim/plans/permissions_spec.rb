# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { plan.creator_author }
  let(:context) do
    {
      current_component: plan_component,
      current_settings: current_settings,
      plan: plan,
      component_settings: component_settings
    }
  end
  let(:plan_component) { create :plan_component }
  let(:plan) { create :plan, component: plan_component }
  let(:component_settings) do
    double(vote_limit: 2)
  end
  let(:current_settings) do
    double(settings.merge(extra_settings))
  end
  let(:settings) do
    {
      creation_enabled?: false
    }
  end
  let(:extra_settings) { {} }
  let(:permission_action) { Decidim::PermissionAction.new(action) }

  context "when scope is admin" do
    let(:action) do
      { scope: :admin, action: :vote, subject: :plan }
    end

    it_behaves_like "delegates permissions to", Decidim::Plans::Admin::Permissions
  end

  context "when scope is not public" do
    let(:action) do
      { scope: :foo, action: :vote, subject: :plan }
    end

    it_behaves_like "permission is not set"
  end

  context "when subject is not a plan" do
    let(:action) do
      { scope: :public, action: :vote, subject: :foo }
    end

    it_behaves_like "permission is not set"
  end

  context "when creating a plan" do
    let(:action) do
      { scope: :public, action: :create, subject: :plan }
    end

    context "when creation is disabled" do
      let(:extra_settings) { { creation_enabled?: false } }

      it { is_expected.to eq false }
    end

    context "when user is authorized" do
      let(:extra_settings) { { creation_enabled?: true } }

      it { is_expected.to eq true }
    end
  end

  context "when editing a plan" do
    let(:action) do
      { scope: :public, action: :edit, subject: :plan }
    end

    before do
      allow(plan).to receive(:open?).and_return(true)
      allow(plan).to receive(:editable_by?).with(user).and_return(editable)
    end

    context "when plan is editable" do
      let(:editable) { true }

      it { is_expected.to eq true }
    end

    context "when plan is not editable" do
      let(:editable) { false }

      it { is_expected.to eq false }
    end
  end

  context "when withdrawing a plan" do
    let(:action) do
      { scope: :public, action: :withdraw, subject: :plan }
    end

    context "when plan author is the user trying to withdraw" do
      it { is_expected.to eq true }
    end

    context "when trying by another user" do
      let(:user) { build :user }

      it { is_expected.to eq false }
    end
  end

  # describe "endorsing" do
  #   let(:action) do
  #     { scope: :public, action: :endorse, subject: :plan }
  #   end
  #
  #   context "when endorsements are disabled" do
  #     let(:extra_settings) do
  #       {
  #         endorsements_enabled?: false,
  #         endorsements_blocked?: false
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when endorsements are blocked" do
  #     let(:extra_settings) do
  #       {
  #         endorsements_enabled?: true,
  #         endorsements_blocked?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when user is authorized" do
  #     let(:extra_settings) do
  #       {
  #         endorsements_enabled?: true,
  #         endorsements_blocked?: false
  #       }
  #     end
  #
  #     it { is_expected.to eq true }
  #   end
  # end

  # describe "endorsing" do
  #   let(:action) do
  #     { scope: :public, action: :unendorse, subject: :plan }
  #   end
  #
  #   context "when endorsements are disabled" do
  #     let(:extra_settings) do
  #       {
  #         endorsements_enabled?: false
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when user is authorized" do
  #     let(:extra_settings) do
  #       {
  #         endorsements_enabled?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq true }
  #   end
  # end

  # describe "voting" do
  #   let(:action) do
  #     { scope: :public, action: :vote, subject: :plan }
  #   end
  #
  #   context "when voting is disabled" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: false,
  #         votes_blocked?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when votes are blocked" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: true,
  #         votes_blocked?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when the user has no more remaining votes" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: true,
  #         votes_blocked?: false
  #       }
  #     end
  #
  #     before do
  #       plans = create_list :plan, 2, component: plan_component
  #       create :plan_vote, author: user, plan: plans[0]
  #       create :plan_vote, author: user, plan: plans[1]
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when the user is authorized" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: true,
  #         votes_blocked?: false
  #       }
  #     end
  #
  #     it { is_expected.to eq true }
  #   end
  # end

  # describe "unvoting" do
  #   let(:action) do
  #     { scope: :public, action: :unvote, subject: :plan }
  #   end
  #
  #   context "when voting is disabled" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: false,
  #         votes_blocked?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when votes are blocked" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: true,
  #         votes_blocked?: true
  #       }
  #     end
  #
  #     it { is_expected.to eq false }
  #   end
  #
  #   context "when the user is authorized" do
  #     let(:extra_settings) do
  #       {
  #         votes_enabled?: true,
  #         votes_blocked?: false
  #       }
  #     end
  #
  #     it { is_expected.to eq true }
  #   end
  # end
end
