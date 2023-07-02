# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::DestroyPlan do
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:state) { :published }
  let(:author) { create :user, :confirmed, organization: organization }
  let(:non_author) { create :user, :confirmed, organization: organization }
  let(:plan_published) { create(:plan, state, component: component, users: [author]) }
  let(:plan_draft) { create(:plan, state, component: component, users: [author]) }

  describe "call" do
    describe "when called for draft plan" do
      subject { described_class.new(plan_draft, author) }

      let(:state) { :unpublished }

      it "broadcasts ok" do
        expect(plan_draft).to receive(:destroy!)
        expect { subject.call }.to broadcast(:ok)
      end

      describe "with non-author current user" do
        subject { described_class.new(plan_draft, non_author) }

        it "broadcasts invalid" do
          expect { subject.call }.to broadcast(:invalid)
        end
      end
    end

    describe "when called for published plan" do
      subject { described_class.new(plan_published, author) }

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
