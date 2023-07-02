# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Plan search", type: :request do
  include Decidim::ComponentPathHelper

  subject { response.body }

  let(:component) { create(:component, manifest_name: "plans") }
  let(:organization) { component.organization }
  let(:participatory_space) { component.participatory_space }
  let(:user) { create(:user, :confirmed, organization: component.organization) }

  let(:filter_params) { {} }
  let(:request_path) { Decidim::EngineRouter.main_proxy(component).plans_path }
  let(:search_resources) { nil }

  before do
    search_resources

    get(
      request_path,
      params: { filter: filter_params, per_page: 100 },
      headers: { "HOST" => component.organization.host }
    )
  end

  it_behaves_like "a resource search with scopes", :plan
  it_behaves_like "a resource search with categories", :plan

  context "without filters" do
    let(:plan) { create(:plan, component: component) }
    let(:other_plan) { create(:plan) }
    let(:search_resources) { plan && other_plan }

    it "only includes plans from the given component" do
      expect(subject).to have_escaped_html(translated(plan.title))
      expect(subject).not_to have_escaped_html(translated(other_plan.title))
    end
  end

  describe "text filter" do
    let(:filter_params) { { search_text: search_text } }

    let(:search_text) { translated(plan_to_find.title) }
    let(:plan_to_find) { create(:plan, title: { en: "This plan should be in the results" }, component: component) }
    let(:other_plans) { create_list(:plan, 10, component: component) }
    let(:search_resources) { plan_to_find && other_plans }

    it "displays the matching plan" do
      expect(subject).to have_escaped_html(translated(plan_to_find.title))

      other_plans.each do |pl|
        expect(subject).not_to have_escaped_html(translated(pl.title))
      end
    end

    context "when filtering based on text section content" do
      let(:search_text) { "appears within a content" }
      let(:content) { create(:content, :field_text, plan: plan_to_find, body: { en: "This content appears within a content section." }) }
      let(:search_resources) { plan_to_find && other_plans && content }

      it "displays the matching plan" do
        expect(subject).to have_escaped_html(translated(plan_to_find.title))

        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end
  end

  describe "origin filter" do
    let(:filter_params) { { with_any_origin: origin } }

    context "when filtering official plans" do
      let(:origin) { "official" }

      let(:official_plans) { create_list(:plan, 3, :official, component: component) }
      let(:other_plans) { create_list(:plan, 5, component: component) }
      let(:search_resources) { official_plans && other_plans }

      it "returns only official plans" do
        official_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "when filtering participant plans" do
      let(:origin) { "participants" }

      let(:official_plans) { create_list(:plan, 3, :official, component: component) }
      let(:participant_plans) { create_list(:plan, 5, component: component) }
      let(:search_resources) { official_plans && participant_plans }

      it "returns only participants plans" do
        participant_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        official_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end
  end

  describe "availability filter" do
    let(:filter_params) { { with_availability: availability } }

    let(:other_plans) { create_list(:plan, 3, component: component) }
    let(:withdrawn_plans) { create_list(:plan, 3, :withdrawn, component: component) }
    let(:search_resources) { other_plans && withdrawn_plans }

    context "when filtering with empty availability" do
      let(:availability) { "" }

      it "returns all except withdrawn plans" do
        other_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        withdrawn_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "when filtering withdrawn plans" do
      let(:availability) { "withdrawn" }

      it "returns only withdrawn plans" do
        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end

        withdrawn_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
      end
    end
  end

  describe "state filter" do
    let(:filter_params) { { with_any_state: state } }
    let(:state) { %w(accepted rejected evaluating not_answered) }

    let(:withdrawn_plans) { create_list(:plan, 3, :withdrawn, component: component) }
    let(:other_plans) { create_list(:plan, 3, component: component) }
    let(:search_resources) { withdrawn_plans && other_plans }

    context "when filtering for default states" do
      it "returns all except withdrawn plans" do
        withdrawn_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end

        other_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "when filtering except_rejected plans" do
      let(:state) { "except_rejected" }

      let(:withdrawn_plan) { create(:plan, :withdrawn, component: component) }
      let(:rejected_plan) { create(:plan, :rejected, component: component) }
      let(:accepted_plan) { create(:plan, :accepted, component: component) }
      let(:unanswered_plan) { create(:plan, component: component) }
      let(:search_resources) { withdrawn_plan && rejected_plan && accepted_plan && unanswered_plan }

      it "hides withdrawn and rejected plans" do
        expect(subject).to have_escaped_html(translated(unanswered_plan.title))
        expect(subject).to have_escaped_html(translated(accepted_plan.title))

        expect(subject).not_to have_escaped_html(translated(rejected_plan.title))
        expect(subject).not_to have_escaped_html(translated(withdrawn_plan.title))
      end
    end

    context "when filtering accepted plans" do
      let(:state) { "accepted" }

      let(:accepted_plans) { create_list(:plan, 3, :accepted, component: component) }
      let(:other_plans) { create_list(:plan, 3, component: component) }
      let(:search_resources) { accepted_plans && other_plans }

      it "returns only accepted plans" do
        accepted_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "when filtering rejected plans" do
      let(:state) { "rejected" }

      let(:rejected_plans) { create_list(:plan, 3, :rejected, component: component) }
      let(:other_plans) { create_list(:plan, 3, component: component) }
      let(:search_resources) { rejected_plans && other_plans }

      it "returns only rejected plans" do
        rejected_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end
  end

  describe "related_to filter" do
    let(:filter_params) { { related_to: related_to } }

    context "when filtering by related to resources" do
      let(:related_to) { "Decidim::DummyResources::DummyResource".underscore }
      let(:dummy_component) { create(:component, manifest_name: "dummy", participatory_space: participatory_space) }
      let(:dummy_resource) { create :dummy_resource, component: dummy_component }

      let(:related_plan) { create(:plan, :accepted, component: component) }
      let(:related_plan2) { create(:plan, :accepted, component: component) }
      let(:other_plans) { create_list(:plan, 3, component: component) }
      let(:search_resources) do
        other_plans

        dummy_resource.link_resources([related_plan], "included_plans")
        related_plan2.link_resources([dummy_resource], "included_plans")
      end

      it "returns only plans related to results" do
        [related_plan, related_plan2].each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end

        other_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end
  end

  describe "tags filter" do
    let(:filter_params) { { with_any_tag: tags } }

    context "with no tags" do
      let(:tags) { [] }

      let(:plans) { create_list(:plan, 10, component: component) }
      let(:search_resources) { plans }

      it "does not filter by tags" do
        plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "with a single tag" do
      let(:tags) { [tag.id] }
      let(:tag) { create(:tag, organization: organization) }
      let(:loose_tag) { create(:tag, organization: organization) }

      let(:tagged_plans) { create_list(:plan, 10, component: component, tags: [tag]) }
      let(:not_tagged_plans) { create_list(:plan, 10, component: component) }
      let(:search_resources) { tagged_plans && not_tagged_plans }

      it "filters by tags" do
        tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        not_tagged_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "with multiple tags" do
      let(:tags) { [tag1.id, tag2.id] }
      let(:tag1) { create(:tag, organization: organization) }
      let(:tag2) { create(:tag, organization: organization) }
      let(:loose_tag) { create(:tag, organization: organization) }

      let(:tagged_plans) { create_list(:plan, 10, component: component, tags: [tag1]) }
      let(:other_tagged_plans) { create_list(:plan, 10, component: component, tags: [tag2]) }
      let(:not_tagged_plans) { create_list(:plan, 10, component: component) }
      let(:search_resources) { tagged_plans && other_tagged_plans && not_tagged_plans }

      it "filters by tags" do
        tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        other_tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        not_tagged_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end

    context "with multiple tags and some plans matching all the tags" do
      let(:tags) { [tag1.id, tag2.id] }
      let(:tag1) { create(:tag, organization: organization) }
      let(:tag2) { create(:tag, organization: organization) }
      let(:loose_tag) { create(:tag, organization: organization) }

      let(:tagged_plans) { create_list(:plan, 10, component: component, tags: [tag1]) }
      let(:other_tagged_plans) { create_list(:plan, 10, component: component, tags: [tag2]) }
      let(:both_tagged_plans) { create_list(:plan, 10, component: component, tags: [tag1, tag2]) }
      let(:not_tagged_plans) { create_list(:plan, 10, component: component) }
      let(:search_resources) { tagged_plans && other_tagged_plans && both_tagged_plans && not_tagged_plans }

      it "filters by tags" do
        tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        other_tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        both_tagged_plans.each do |pl|
          expect(subject).to have_escaped_html(translated(pl.title))
        end
        not_tagged_plans.each do |pl|
          expect(subject).not_to have_escaped_html(translated(pl.title))
        end
      end
    end
  end
end
