# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::OrganizationTags do
  let(:organization) { create(:organization) }
  let(:other_organization) { create(:organization) }
  let(:tags) { create_list(:tag, 5, organization: organization) }
  let(:other_tags) { create_list(:tag, 3, organization: other_organization) }

  let(:subject) { described_class.new(organization) }

  it "returns plans included in the organization" do
    expect(subject).to match_array(tags)
  end
end
