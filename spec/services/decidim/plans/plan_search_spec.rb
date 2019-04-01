# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanSearch do
      let(:component) { create(:component, manifest_name: "plans") }
      let(:organization) { component.organization }
      let(:scope1) { create :scope, organization: component.organization }
      let(:scope2) { create :scope, organization: component.organization }
      let(:subscope1) { create :scope, organization: component.organization, parent: scope1 }
      let(:participatory_process) { component.participatory_space }
      let(:user) { create(:user, organization: component.organization) }
      let!(:plan) { create(:plan, component: component, scope: scope1) }

      describe "results" do
        subject do
          described_class.new(
            component: component,
            organization: organization,
            activity: activity,
            search_text: search_text,
            state: state,
            origin: origin,
            related_to: related_to,
            scope_id: scope_id,
            current_user: user,
            tag_id: tag_id
          ).results
        end

        let(:activity) { [] }
        let(:search_text) { nil }
        let(:origin) { nil }
        let(:related_to) { nil }
        let(:state) { "not_withdrawn" }
        let(:scope_id) { nil }
        let(:tag_id) { [] }

        it "only includes plans from the given component" do
          other_plan = create(:plan)

          expect(subject).to include(plan)
          expect(subject).not_to include(other_plan)
        end

        describe "search_text filter" do
          let(:search_text) { "dog" }

          it "returns the plans containing the search in the title or the body" do
            create_list(:plan, 3, component: component)
            create(:plan, title: { en: "A dog" }, component: component)
            create(:plan, title: { en: "There is a dog in the office" }, component: component)

            expect(subject.size).to eq(2)
          end
        end

        describe "origin filter" do
          context "when filtering official plans" do
            let(:origin) { "official" }

            it "returns only official plans" do
              official_plans = create_list(:plan, 3, :official, component: component)
              create_list(:plan, 5, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(official_plans)
            end
          end

          context "when filtering citizen plans" do
            let(:origin) { "citizens" }
            let(:another_user) { create(:user, organization: component.organization) }

            it "returns only citizen plans" do
              create_list(:plan, 3, :official, component: component)
              citizen_plans = create_list(:plan, 5, component: component)
              citizen_plans << plan

              expect(subject.size).to eq(6)
              expect(subject).to match_array(citizen_plans)
            end
          end
        end

        describe "state filter" do
          context "when filtering for default states" do
            it "returns all except withdrawn plans" do
              create_list(:plan, 3, :withdrawn, component: component)
              other_plans = create_list(:plan, 3, component: component)
              other_plans << plan

              expect(subject.size).to eq(4)
              expect(subject).to match_array(other_plans)
            end
          end

          context "when filtering :except_rejected plans" do
            let(:state) { "except_rejected" }

            it "hides withdrawn and rejected plans" do
              create(:plan, :withdrawn, component: component)
              create(:plan, :rejected, component: component)
              accepted_plan = create(:plan, :accepted, component: component)

              expect(subject.size).to eq(2)
              expect(subject).to match_array([accepted_plan, plan])
            end
          end

          context "when filtering accepted plans" do
            let(:state) { "accepted" }

            it "returns only accepted plans" do
              accepted_plans = create_list(:plan, 3, :accepted, component: component)
              create_list(:plan, 3, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(accepted_plans)
            end
          end

          context "when filtering rejected plans" do
            let(:state) { "rejected" }

            it "returns only rejected plans" do
              create_list(:plan, 3, component: component)
              rejected_plans = create_list(:plan, 3, :rejected, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(rejected_plans)
            end
          end

          context "when filtering withdrawn plans" do
            let(:state) { "withdrawn" }

            it "returns only withdrawn plans" do
              create_list(:plan, 3, component: component)
              withdrawn_plans = create_list(:plan, 3, :withdrawn, component: component)

              expect(subject.size).to eq(3)
              expect(subject).to match_array(withdrawn_plans)
            end
          end
        end

        describe "scope_id filter" do
          let!(:plan2) { create(:plan, component: component, scope: scope2) }
          let!(:plan3) { create(:plan, component: component, scope: subscope1) }

          context "when a parent scope id is being sent" do
            let(:scope_id) { scope1.id }

            it "filters plans by scope" do
              expect(subject).to match_array [plan, plan3]
            end
          end

          context "when a subscope id is being sent" do
            let(:scope_id) { subscope1.id }

            it "filters plans by scope" do
              expect(subject).to eq [plan3]
            end
          end

          context "when multiple ids are sent" do
            let(:scope_id) { [scope2.id, scope1.id] }

            it "filters plans by scope" do
              expect(subject).to match_array [plan, plan2, plan3]
            end
          end

          context "when `global` is being sent" do
            let!(:resource_without_scope) { create(:plan, component: component, scope: nil) }
            let(:scope_id) { ["global"] }

            it "returns plans without a scope" do
              expect(subject).to eq [resource_without_scope]
            end
          end

          context "when `global` and some ids is being sent" do
            let!(:resource_without_scope) { create(:plan, component: component, scope: nil) }
            let(:scope_id) { ["global", scope2.id, scope1.id] }

            it "returns plans without a scope and with selected scopes" do
              expect(subject).to match_array [resource_without_scope, plan, plan2, plan3]
            end
          end
        end

        describe "related_to filter" do
          context "when filtering by related to resources" do
            let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }
            let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space: participatory_process) }
            let(:dummy_resource) { create :dummy_resource, component: dummy_component }

            it "returns only plans related to results" do
              related_plan = create(:plan, :accepted, component: component)
              related_plan2 = create(:plan, :accepted, component: component)
              create_list(:plan, 3, component: component)
              dummy_resource.link_resources([related_plan], "included_plans")
              related_plan2.link_resources([dummy_resource], "included_plans")

              expect(subject).to match_array([related_plan, related_plan2])
            end
          end
        end

        describe "tag_id filter" do
          context "when tag_id is empty" do
            let(:other_component) { create(:component, manifest_name: "plans", organization: organization) }

            let!(:plans) { create_list(:plan, 10, component: component) }
            let!(:other_plans) { create_list(:plan, 10, component: other_component) }

            it "does not filter by tags" do
              expect(subject.count).to eq(11)
            end
          end

          context "when tag_id is not set" do
            let(:other_component) { create(:component, manifest_name: "plans", organization: organization) }
            let(:tag_id) { nil }

            let!(:plans) { create_list(:plan, 10, component: component) }
            let!(:other_plans) { create_list(:plan, 10, component: other_component) }

            it "does not filter by tags" do
              expect(subject.count).to eq(11)
            end
          end

          context "when tag_id is set" do
            let(:other_component) { create(:component, manifest_name: "plans", organization: organization) }
            let(:tag) { create(:tag, organization: organization) }
            let(:loose_tag) { create(:tag, organization: organization) }
            let(:tag_id) { [tag.id] }

            let!(:tagged_plans) { create_list(:plan, 10, component: component, tags: [tag]) }
            let!(:not_tagged_plans) { create_list(:plan, 10, component: component) }
            let!(:other_plans) { create_list(:plan, 10, component: other_component) }

            it "does filters by tags" do
              expect(subject.count).to eq(10)
            end
          end

          context "when tag_id is multiple tags" do
            let(:other_component) { create(:component, manifest_name: "plans", organization: organization) }
            let(:tag1) { create(:tag, organization: organization) }
            let(:tag2) { create(:tag, organization: organization) }
            let(:loose_tag) { create(:tag, organization: organization) }
            let(:tag_id) { [tag1.id, tag2.id] }

            let!(:tagged_plans) { create_list(:plan, 10, component: component, tags: [tag1]) }
            let!(:other_tagged_plans) { create_list(:plan, 10, component: component, tags: [tag2]) }
            let!(:other_plans) { create_list(:plan, 10, component: other_component) }

            it "does filters by tags" do
              expect(subject.count).to eq(20)
            end
          end
        end
      end
    end
  end
end
