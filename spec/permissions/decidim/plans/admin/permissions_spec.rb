# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::Permissions do
  subject { described_class.new(user, permission_action, context).permissions.allowed? }

  let(:user) { build(:user) }
  let(:current_component) { create(:plan_component) }
  let(:plan) { nil }
  let(:context) do
    {
      plan:,
      current_component:,
      current_settings:,
      component_settings:
    }
  end
  let(:component_settings) do
    double(
      plan_answering_enabled: component_settings_plan_answering_enabled?,
      participatory_texts_enabled?: component_settings_participatory_texts_enabled?
    )
  end
  let(:current_settings) do
    double(
      creation_enabled?: creation_enabled?,
      plan_answering_enabled: current_settings_plan_answering_enabled?
    )
  end
  let(:creation_enabled?) { true }
  let(:component_settings_plan_answering_enabled?) { true }
  let(:component_settings_participatory_texts_enabled?) { true }
  let(:current_settings_plan_answering_enabled?) { true }
  let(:permission_action) { Decidim::PermissionAction.new(**action) }

  context "with plans" do
    # describe "plan note creation" do
    #   let(:action) do
    #     { scope: :admin, action: :create, subject: :plan_note }
    #   end
    #
    #   context "when the space allows it" do
    #     it { is_expected.to eq true }
    #   end
    # end

    describe "plan creation" do
      let(:action) do
        { scope: :admin, action: :create, subject: :plan }
      end

      it { is_expected.to be true }
    end

    describe "plan edition" do
      let(:action) do
        { scope: :admin, action: :edit, subject: :plan }
      end

      let(:plan) { create(:plan, component: current_component) }

      it { is_expected.to be true }
    end

    describe "plan answering" do
      let(:action) do
        { scope: :admin, action: :create, subject: :plan_answer }
      end

      context "when everything is OK" do
        it { is_expected.to be true }
      end

      context "when answering is disabled in the step level" do
        let(:current_settings_plan_answering_enabled?) { false }

        it { is_expected.to be false }
      end

      context "when answering is disabled in the component level" do
        let(:component_settings_plan_answering_enabled?) { false }

        it { is_expected.to be false }
      end
    end

    describe "plan closing" do
      let(:action) do
        { scope: :admin, action: :close, subject: :plan }
      end

      let(:plan) { create(:plan, component: current_component) }

      it { is_expected.to be true }
    end

    describe "plan budget exporting" do
      let(:action) do
        { scope: :admin, action: :export_budgets, subject: :plans }
      end

      it { is_expected.to be true }
    end
  end
end
