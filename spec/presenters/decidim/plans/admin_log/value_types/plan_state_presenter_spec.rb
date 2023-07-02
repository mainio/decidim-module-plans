# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module AdminLog
      module ValueTypes
        describe PlanStatePresenter do
          subject { described_class.new(plan.state, helpers) }
          let(:helpers) { ActionController::Base.helpers }

          describe "#present" do
            context "when evaluating" do
              let(:plan) { create(:plan, :evaluating) }

              it "returns Decidim::Plans::Log::ResourcePresenter" do
                expect(subject.present).to eq("Evaluating")
              end
            end
          end
        end
      end
    end
  end
end
