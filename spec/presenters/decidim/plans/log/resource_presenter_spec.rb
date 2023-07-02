# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Log
      describe ResourcePresenter do
        subject { described_class.new(log.resource, helpers, log.extra["resource"]) }

        let(:helpers) { ActionController::Base.helpers }
        let(:plan) { create(:plan) }
        let(:component) { plan.component }
        let(:log) { create(:action_log, action: "publish", visibility: "all", resource: plan, organization: component.organization, participatory_space: component.participatory_space) }

        describe "#present_resource_name" do
          it "returns title in current locale" do
            expect(subject.send(:present_resource_name)).to eq(plan.title["en"])
          end
        end
      end
    end
  end
end
