# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanBuilder do
      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization:) }

      describe "#create" do
        let(:attributes) do
          {
            title: { en: "Lorem ipsum dolor" },
            component:,
            published_at: Time.current
          }
        end

        it "creates a new plan" do
          expect do
            subject.create(
              attributes:,
              author:,
              action_user: author
            )
          end.to change(Decidim::Plans::Plan, :count).by(1)
        end
      end

      describe "#copy" do
        let(:other_component) { create(:plan_component, organization:) }
        let(:plan) { create(:plan, component:) }

        it "creates a new plan" do
          original_plan = plan
          expect do
            subject.copy(
              original_plan,
              author:,
              action_user: author,
              extra_attributes: { component: other_component },
              skip_link: true
            )
          end.to change(Decidim::Plans::Plan, :count).by(1)
        end
      end
    end
  end
end
