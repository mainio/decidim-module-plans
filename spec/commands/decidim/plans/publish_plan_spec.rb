# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PublishPlan do
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:state) { :unpublished }
  let(:author) { create :user, :confirmed, organization: organization }
  let(:non_author) { create :user, :confirmed, organization: organization }
  let(:plan) { create(:plan, state, component: component, users: [author]) }

  describe "call" do
    context "when called by the author" do
      let(:subject) do
        described_class.new(plan, author)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(plan.published_at).not_to be_nil
      end
    end

    context "when called by non-author" do
      let(:subject) do
        described_class.new(plan, non_author)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
