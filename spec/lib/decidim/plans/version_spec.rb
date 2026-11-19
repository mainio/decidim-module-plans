# frozen_string_literal: true

require "spec_helper"

describe "Decidim::Plans" do
  it "is defined and follows semantic versioning format" do
    expect(Decidim::Plans.version).to match(/\A\d+\.\d+\.\d+/)
  end
end
