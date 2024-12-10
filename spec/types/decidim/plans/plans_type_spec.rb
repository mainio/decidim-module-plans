# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"
require "decidim/core/test"

module Decidim
  module Plans
    describe PlansType, type: :graphql do
      include_context "with a graphql class type"
      let(:model) { create(:plan_component) }

      it_behaves_like "a component query type"

      describe "plans" do
        let!(:draft_plans) { create_list(:plan, 2, :draft, component: model) }
        let!(:published_plans) { create_list(:plan, 2, :published, component: model) }
        let!(:other_plans) { create_list(:plan, 2, :unpublished) }

        let(:query) { "{ plans { edges { node { id } } } }" }

        it "returns the published plans" do
          ids = response["plans"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*published_plans.map(&:id).map(&:to_s))
          expect(ids).not_to include(*draft_plans.map(&:id).map(&:to_s))
          expect(ids).not_to include(*other_plans.map(&:id).map(&:to_s))
        end
      end

      describe "sections" do
        let(:query) { "{ sections { edges { node { id } } } }" }
        let!(:generated_sections) { create_list(:section, 3, component: model) }

        let(:sections) do
          Section.where(component: model).order(:position)
        end

        it "returns the component sections" do
          ids = response["sections"]["edges"].map { |edge| edge["node"]["id"] }
          expect(ids).to include(*sections.map(&:id).map(&:to_s))
        end
      end

      describe "plan" do
        let(:query) { "query Plan($id: ID!){ plan(id: $id) { id } }" }
        let(:variables) { { id: plan.id.to_s } }

        context "when the plan belongs to the component" do
          let!(:plan) { create(:plan, component: model) }

          it "finds the plan" do
            expect(response["plan"]["id"]).to eq(plan.id.to_s)
          end
        end

        context "when the plan doesn't belong to the component" do
          let!(:plan) { create(:plan, component: create(:plan_component)) }

          it "returns null" do
            expect(response["plan"]).to be_nil
          end
        end
      end
    end
  end
end
