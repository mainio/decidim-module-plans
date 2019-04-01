# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Tag do
      subject { tag }

      let(:component) { build :plan_component }
      let(:organization) { component.participatory_space.organization }
      let(:plan) { create(:plan, component: component) }
      let(:tag) { build(:tag, organization: organization) }

      it { is_expected.to be_valid }

      context "when there is no organization" do
        let(:organization) { nil }

        it { is_expected.not_to be_valid }
      end

      context "when there are taggings" do
        let!(:tagged) { create_list(:plan, 10, component: component, tags: [tag]) }

        it "returns the taggings" do
          expect(
            tag.plan_taggings.collect { |pt| pt.plan.id }
          ).to match_array(tagged.pluck(:id))
        end

        it "destroys the taggings when the plan is destroyed" do
          tagged.each(&:destroy!)

          expect(Decidim::Plans::PlanTagging.count).to eq(0)
          expect(described_class.count).to eq(1)
        end
      end

      describe "#plan_taggings_count" do
        context "when the tag has no taggings" do
          it "is zero" do
            expect(tag.plan_taggings_count).to eq(0)
          end
        end

        context "when the tag has taggings" do
          let!(:tagged) { create_list(:plan, 10, component: component, tags: [tag]) }

          it "is the amount of taggings" do
            expect(tag.plan_taggings_count).to eq(tagged.count)
          end
        end
      end
    end
  end
end
