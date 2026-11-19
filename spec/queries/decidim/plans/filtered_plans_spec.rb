# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::FilteredPlans do
  let(:organization) { create(:organization, tos_version: Time.current) }

  context "with single component" do
    subject { described_class.new(component).query }

    let(:component) { create(:plan_component, organization:) }
    let(:other_component) { create(:plan_component, organization:) }

    let!(:plans) { create_list(:plan, 5, component:) }
    let!(:other_plans) { create_list(:plan, 6, component: other_component) }

    it "returns plans included in the provided components" do
      expect(subject).to match_array(plans)
    end
  end

  context "with multiple components" do
    subject { described_class.new([first_component, second_component]).query }

    let(:first_component) { create(:plan_component, organization:) }
    let(:second_component) { create(:plan_component, organization:) }
    let(:other_component) { create(:plan_component, organization:) }

    let!(:first_c_plans) { create_list(:plan, 5, component: first_component) }
    let!(:second_c_plans) { create_list(:plan, 3, component: second_component) }
    let!(:other_plans) { create_list(:plan, 6, component: other_component) }

    it "returns plans included in the provided components" do
      expect(subject).to match_array(first_c_plans + second_c_plans)
    end
  end

  context "with start time" do
    subject { described_class.new(component, start_time).query }

    let(:start_time) { Time.current.midday - 1.day }

    let(:component) { create(:plan_component, organization:) }

    let!(:plans) { create_list(:plan, 5, component:, created_at: start_time) }
    let!(:new_plans) { create_list(:plan, 5, component:, created_at: start_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component:, created_at: start_time - 1.hour) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(plans.pluck(:id) + new_plans.pluck(:id))
    end
  end

  context "with end time" do
    subject { described_class.new(component, nil, end_time).query }

    let(:end_time) { Time.current.midday - 1.day }

    let(:component) { create(:plan_component, organization:) }

    let!(:plans) { create_list(:plan, 5, component:, created_at: end_time) }
    let!(:new_plans) { create_list(:plan, 5, component:, created_at: end_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component:, created_at: end_time - 1.hour) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(plans.pluck(:id) + old_plans.pluck(:id))
    end
  end

  context "with start and end time" do
    subject { described_class.new(component, start_time, end_time).query }

    let(:start_time) { Time.current.midday - 2.days }
    let(:end_time) { start_time + 1.day }

    let(:component) { create(:plan_component, organization:) }

    let!(:start_plans) { create_list(:plan, 5, component:, created_at: start_time) }
    let!(:end_plans) { create_list(:plan, 5, component:, created_at: end_time) }
    let!(:mid_plans) { create_list(:plan, 5, component:, created_at: start_time + 1.hour) }

    let!(:new_plans) { create_list(:plan, 5, component:, created_at: end_time + 1.hour) }
    let!(:old_plans) { create_list(:plan, 5, component:, created_at: start_time - 1.hour) }

    it "returns plans created at the start time or after it" do
      expect(subject.pluck(:id)).to match_array(start_plans.pluck(:id) + end_plans.pluck(:id) + mid_plans.pluck(:id))
    end
  end
end
