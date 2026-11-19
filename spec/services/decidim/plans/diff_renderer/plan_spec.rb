# frozen_string_literal: true

require "spec_helper"
require "paper_trail/frameworks/rspec"

module Decidim
  module Plans
    describe DiffRenderer::Plan do
      let(:component) { create(:plan_component) }
      let(:participatory_space) { component.participatory_space }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization:) }
      let(:category) { create(:category, participatory_space:) }

      with_versioning do
        let(:original_title) { "Original title" }
        let(:original_state) { "evaluating" }
        let(:original_scope) { create(:scope, organization:) }
        let(:plan) do
          create(
            :plan,
            component:,
            scope: original_scope,
            title: { en: original_title },
            state: original_state
          )
        end

        describe "#diff" do
          subject { described_class.new(version, "en") }

          let(:other_category) { create(:category, participatory_space:) }
          let(:version) { plan.versions.last }
          let(:new_title) { "New title" }
          let(:new_state) { "accepted" }
          let(:new_scope) { create(:scope, organization:) }

          before do
            plan.update(
              scope: new_scope,
              title: { en: new_title },
              state: new_state
            )
          end

          it "renders correct diff" do
            expect(subject.diff).to include(
              title_en: {
                type: :string,
                label: "Title",
                old_value: original_title,
                new_value: new_title
              },
              state: {
                type: :string,
                label: "State",
                old_value: original_state,
                new_value: new_state
              },
              decidim_scope_id: {
                type: :scope,
                label: "Scope",
                old_value: original_scope.id,
                new_value: new_scope.id
              }
            )
          end
        end
      end
    end
  end
end
