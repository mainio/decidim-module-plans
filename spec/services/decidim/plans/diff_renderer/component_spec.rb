# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

module Decidim
  module Plans
    describe DiffRenderer::Component do
      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization: organization) }

      with_versioning do
        let(:plan) { create(:plan, component: component) }

        describe "#diff" do
          subject { described_class.new(version, "en") }

          let(:other_component) { create(:plan_component, organization: organization) }
          let(:version) { plan.versions.last }

          before do
            plan.update(component: other_component)
          end

          it "renders correct diff" do
            expect(subject.diff).to include(
              decidim_component_id: {
                type: :component,
                label: "Component",
                old_value: component.id,
                new_value: other_component.id
              }
            )
          end
        end
      end
    end
  end
end
