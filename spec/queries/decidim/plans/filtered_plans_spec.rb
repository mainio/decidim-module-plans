# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::FilteredPlans do
  let(:organization) { create(:organization) }

  context "with single component" do
    let(:component) { create(:plan_component, organization: organization) }
    let(:other_component) { create(:plan_component, organization: organization) }

    let!(:plans) { create_list(:plan, 5, component: component) }
    let!(:other_plans) { create_list(:plan, 6, component: other_component) }

    let(:subject) { described_class.new(component) }

    it "returns plans included in the provided components" do
      expect(subject).to match_array(plans)
    end
  end

  context "with multiple components" do
    let(:component1) { create(:plan_component, organization: organization) }
    let(:component2) { create(:plan_component, organization: organization) }
    let(:other_component) { create(:plan_component, organization: organization) }

    let!(:c1_plans) { create_list(:plan, 5, component: component1) }
    let!(:c2_plans) { create_list(:plan, 3, component: component2) }
    let!(:other_plans) { create_list(:plan, 6, component: other_component) }

    let(:subject) { described_class.new([component1, component2]) }

    it "returns plans included in the provided components" do
      expect(subject).to match_array(c1_plans + c2_plans)
    end
  end

  context "with start time" do
    let(:start_time) { Time.current.midday - 1.day }

    let(:component) { create(:plan_component, organization: organization) }

    let!(:plans) { create_list(:plan, 5, component: component, created_at: start_time) }
    let!(:new_plans) { create_list(:plan, 5, component: component, created_at: start_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component: component, created_at: start_time - 1.hour) }

    let(:subject) { described_class.new(component, start_time) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(plans.pluck(:id) + new_plans.pluck(:id))
    end
  end

  context "with end time" do
    let(:end_time) { Time.current.midday - 1.day }

    let(:component) { create(:plan_component, organization: organization) }

    let!(:plans) { create_list(:plan, 5, component: component, created_at: end_time) }
    let!(:new_plans) { create_list(:plan, 5, component: component, created_at: end_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component: component, created_at: end_time - 1.hour) }

    let(:subject) { described_class.new(component, nil, end_time) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(plans.pluck(:id) + old_plans.pluck(:id))
    end
  end

  context "with start and end time" do
    let(:start_time) { Time.current.midday - 2.days }
    let(:end_time) { start_time + 1.day }

    let(:component) { create(:plan_component, organization: organization) }

    let!(:start_plans) { create_list(:plan, 5, component: component, created_at: start_time) }
    let!(:end_plans) { create_list(:plan, 5, component: component, created_at: end_time) }
    let!(:mid_plans) { create_list(:plan, 5, component: component, created_at: start_time + 1.hour) }

    let!(:new_plans) { create_list(:plan, 5, component: component, created_at: end_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component: component, created_at: start_time - 1.hour) }

    let(:subject) { described_class.new(component, start_time, end_time) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(start_plans.pluck(:id) + end_plans.pluck(:id) + mid_plans.pluck(:id))
    end
  end
end
