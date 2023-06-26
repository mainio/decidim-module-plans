# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::ApplicationHelper do
  describe "#humanize_plan_state" do
    context "when default (not_answered)" do
      it "returns the correct translation" do
        expect(helper.humanize_plan_state(:unknown)).to eq("Not answered")
      end
    end

    context "when accepted" do
      it "returns the correct translation" do
        expect(helper.humanize_plan_state(:accepted)).to eq("Accepted")
      end
    end

    context "when evaluating" do
      it "returns the correct translation" do
        expect(helper.humanize_plan_state(:evaluating)).to eq("Evaluating")
      end
    end

    context "when rejected" do
      it "returns the correct translation" do
        expect(helper.humanize_plan_state(:rejected)).to eq("Rejected")
      end
    end

    context "when withdrawn" do
      it "returns the correct translation" do
        expect(helper.humanize_plan_state(:withdrawn)).to eq("Withdrawn")
      end
    end
  end

  describe "#plan_state_css_class" do
    context "when accepted" do
      it "returns the correct class" do
        expect(helper.plan_state_css_class("accepted")).to eq("text-success")
      end
    end

    context "when rejected" do
      it "returns the correct class" do
        expect(helper.plan_state_css_class("rejected")).to eq("text-alert")
      end
    end

    context "when evaluating" do
      it "returns the correct class" do
        expect(helper.plan_state_css_class("evaluating")).to eq("text-warning")
      end
    end

    context "when withdrawn" do
      it "returns the correct class" do
        expect(helper.plan_state_css_class("withdrawn")).to eq("text-alert")
      end
    end

    context "when anything else" do
      it "returns the correct class" do
        expect(helper.plan_state_css_class("lorem")).to eq("text-info")
      end
    end
  end

  describe "#current_user_plans" do
    let(:organization) { current_component.organization }
    let(:current_component) { create :plan_component }
    let(:current_user) { create(:user, :confirmed, organization: organization) }
    let(:another_user) { create(:user, :confirmed, organization: organization) }

    before do
      3.times do
        plan = build(:plan, component: current_component)
        plan.coauthorships.build(author: current_user)
        plan.save!
      end
      2.times do
        plan = build(:plan, component: current_component)
        plan.coauthorships.build(author: another_user)
        plan.save!
      end

      allow(helper).to receive(:current_component).and_return(current_component)
      allow(helper).to receive(:current_user).and_return(current_user)
    end

    it "returns the correct plans" do
      expect(helper.current_user_plans.count).to eq(3)
    end
  end

  describe "#authors_for" do
    let(:organization) { current_component.organization }
    let(:current_component) { create :plan_component }
    let(:authors) { create_list(:user, 4, :confirmed, organization: organization) }
    let(:non_authors) { create_list(:user, 2, :confirmed, organization: organization) }

    it "returns the correct authors" do
      plan = create(:plan, component: current_component, users: authors)

      expect(helper).to receive(:present) { |target| target }.exactly(4).times
      expect(helper.authors_for(plan).count).to eq(4)
    end
  end

  describe "#filter_state_values" do
    it "returns the correct state values" do
      expect(helper.filter_state_values).to match_array(
        [
          %w(all All),
          %w(accepted Accepted),
          %w(rejected Rejected),
          %w(evaluating Evaluating)
        ]
      )
    end
  end

  describe "#filter_type_values" do
    it "returns the correct state values" do
      expect(helper.filter_type_values).to match_array(
        [
          %w(all All),
          %w(plans Proposals),
          %w(amendments Amendments)
        ]
      )
    end
  end

  describe "#tabs_id_for_content" do
    it "returns the correct state values" do
      expect(helper.tabs_id_for_content("test")).to eq("content_test")
    end
  end
end
