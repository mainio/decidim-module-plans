# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

module Decidim
  module Plans
    describe DiffRenderer::Categorization do
      let(:component) { create(:plan_component) }
      let(:participatory_space) { component.participatory_space }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization: organization) }
      let(:category) { create(:category, participatory_space: participatory_space) }

      with_versioning do
        let(:plan) { create(:plan, component: component, category: category) }

        describe "#diff" do
          let(:other_category) { create(:category, participatory_space: participatory_space) }
          let(:version) { plan.categorization.versions.last }
          let(:subject) { described_class.new(version, "en") }

          before do
            plan.update(category: other_category)
          end

          it "renders correct diff" do
            expect(subject.diff).to include(
              decidim_category_id: {
                type: :category,
                label: "Category",
                old_value: category.id,
                new_value: other_category.id
              }
            )
          end
        end
      end
    end
  end
end
