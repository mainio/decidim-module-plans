# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe PlanExportBudgetsForm do
        subject { form }

        let(:component) { create(:plan_component) }
        let(:participatory_space) { component.participatory_space }

        let(:target_component) { create(:budget_component, participatory_space: participatory_space) }
        let(:default_budget) { 50_000 }
        let(:acceptance) { true }
        let(:params) do
          {
            target_component_id: target_component.try(:id),
            default_budget: default_budget,
            export_all_closed_plans: acceptance
          }
        end

        let(:form) do
          described_class.from_params(params).with_context(
            current_component: component,
            current_participatory_space: participatory_space
          )
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when no target component is defined" do
          let(:target_component) { nil }

          it { is_expected.to be_invalid }
        end

        context "when default budget is zero" do
          let(:default_budget) { 0 }

          it { is_expected.to be_invalid }
        end

        context "when acceptance checkbox is not checked" do
          let(:acceptance) { false }

          it { is_expected.to be_invalid }
        end

        describe "#target_component" do
          it "returns a component" do
            expect(subject.target_component).to be_a(Decidim::Component)
          end
        end

        describe "#target_components" do
          it "returns the budgets components in the same participatory space" do
            expect(subject.target_components.count).to eq(1)
          end
        end

        describe "#target_components_collection" do
          it "returns a collection of the budgets components for form select" do
            expect(subject.target_components_collection).to contain_exactly(
              ["Budgets", target_component.id]
            )
          end
        end
      end
    end
  end
end
