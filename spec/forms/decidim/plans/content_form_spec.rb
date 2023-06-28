# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe ContentForm do
      subject { form }

      let(:organization) { create(:organization, tos_version: Time.current) }
      let(:body_en) { "English body" }
      let(:plan) { create :plan }
      let(:plan_id) { plan.id }
      let(:section) { create :section, component: component }
      let(:section_id) { section.id }

      let(:form) do
        described_class.from_params(params).with_context(
          current_organization: organization,
          current_component: component
        )
      end

      context "with multiple languages" do
        let(:component) { create :plan_component, :with_multilingual_answers }
        let(:params) do
          {
            body_en: body_en,
            section_id: section_id,
            plan_id: plan_id
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the section is mandatory" do
          let(:section) { create :section, component: component, mandatory: true }

          context "with body" do
            it { is_expected.to be_valid }
          end

          context "with empty body" do
            let(:body_en) { "" }

            it { is_expected.to be_invalid }
          end
        end
      end

      context "with single language" do
        let(:component) { create :plan_component }
        let(:params) do
          {
            body_en: body_en,
            section_id: section_id,
            plan_id: plan_id
          }
        end

        context "when everything is OK" do
          it { is_expected.to be_valid }
        end

        context "when the section is mandatory" do
          let(:section) { create :section, component: component, mandatory: true }

          context "with body" do
            it { is_expected.to be_valid }
          end

          context "with empty body" do
            let(:body_en) { "" }

            it { is_expected.to be_invalid }
          end
        end
      end
    end
  end
end
