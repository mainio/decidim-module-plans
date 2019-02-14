# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module AdminLog
      describe PlanPresenter do
        let(:helpers) { ActionController::Base.helpers }
        let(:subject) { described_class.new(log, helpers) }
        let(:plan) { create(:plan) }
        let(:component) { plan.component }
        let(:log) { create(:action_log, action: "publish", visibility: "all", resource: plan, organization: component.organization, participatory_space: component.participatory_space) }

        describe "#resource_presenter" do
          it "returns Decidim::Plans::Log::ResourcePresenter" do
            expect(subject.send(:resource_presenter)).to be_a(Decidim::Plans::Log::ResourcePresenter)
          end
        end

        describe "#diff_fields_mapping" do
          it "returns expected values" do
            expect(subject.send(:diff_fields_mapping)).to include(
              state: "Decidim::Plans::AdminLog::ValueTypes::PlanStatePresenter",
              answered_at: :date,
              answer: :i18n
            )
          end
        end

        describe "#i18n_labels_scope" do
          it "returns expected value" do
            expect(subject.send(:i18n_labels_scope)).to eq("activemodel.attributes.plan")
          end
        end
      end
    end
  end
end
