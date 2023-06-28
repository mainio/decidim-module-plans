# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::ComponentPlanTags do
  let(:organization) { create(:organization, tos_version: Time.current) }

  let(:component) { create(:plan_component, organization: organization) }
  let(:other_component) { create(:plan_component, organization: organization) }

  let(:tags) { create_list(:tag, 5, organization: organization) }
  let(:other_tags) { create_list(:tag, 3, organization: organization) }

  let!(:plans) { create_list(:plan, 5, component: component, tags: tags) }
  let!(:other_plans) { create_list(:plan, 6, component: other_component, tags: other_tags) }
  let!(:other_plans_same_tags) { create_list(:plan, 6, component: other_component, tags: tags) }

  let(:subject) { described_class.new(component) }

  it "returns plans included in the organization" do
    expect(subject).to match_array(tags)
  end
end
