# frozen_string_literal: true

require "spec_helper"

describe "Plans component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:plan_component) }
  let!(:current_user) { create(:user, organization: component.participatory_space.organization) }

  describe "on destroy" do
    context "when there are no plans for the component" do
      it "destroys the component" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to change { Decidim::Component.count }.by(-1)

        expect(component).to be_destroyed
      end
    end

    context "when there are plans for the component" do
      before do
        create(:plan, component: component)
      end

      it "raises an error" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to broadcast(:invalid)

        expect(component).not_to be_destroyed
      end
    end
  end

  describe "stats" do
    subject { current_stat[2] }

    let(:raw_stats) do
      Decidim.component_manifests.map do |component_manifest|
        component_manifest.stats.filter(name: stats_name).with_context(component).flat_map { |name, data| [component_manifest.name, name, data] }
      end
    end

    let(:stats) do
      raw_stats.select { |stat| stat[0] == :plans }
    end

    let!(:plan) { create :plan }
    let(:component) { plan.component }
    let!(:hidden_plan) { create :plan, component: component }
    let!(:draft_plan) { create :plan, :draft, component: component }
    let!(:withdrawn_plan) { create :plan, :withdrawn, component: component }
    let!(:moderation) { create :moderation, reportable: hidden_plan, hidden_at: 1.day.ago }

    let(:current_stat) { stats.find { |stat| stat[1] == stats_name } }

    describe "plans_count" do
      let(:stats_name) { :plans_count }

      it "only counts visible plans" do
        expect(Decidim::Plans::Plan.where(component: component).count).to eq 4
        expect(subject).to eq 3
      end
    end

    describe "comments_count" do
      let(:stats_name) { :comments_count }

      before do
        create_list :comment, 2, commentable: plan
        create_list :comment, 3, commentable: hidden_plan
      end

      it "counts the comments from visible plans" do
        expect(Decidim::Comments::Comment.count).to eq 5
        expect(subject).to eq 2
      end
    end
  end
end
