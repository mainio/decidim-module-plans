# frozen_string_literal: true

require "spec_helper"

describe "Plans component" do # rubocop:disable RSpec/DescribeClass
  let!(:component) { create(:plan_component) }
  let!(:current_user) { create(:user, :confirmed, organization: component.participatory_space.organization) }

  describe "on destroy" do
    context "when there are no plans for the component" do
      it "destroys the component" do
        expect do
          Decidim::Admin::DestroyComponent.call(component, current_user)
        end.to change(Decidim::Component, :count).by(-1)

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

  describe "exports" do
    before do
      create_list(:plan, 10, :published, component: component)
    end

    it "includes plans export collection" do
      expect(component.manifest.export_manifests.map(&:name)).to include(:plans)

      e_plans = component.manifest.export_manifests.find { |m| m.name == :plans }
      expect(e_plans.include_in_open_data).to be(true)
      expect(e_plans.collection.call(component).count).to eq(10)
      expect(e_plans.serializer).to be(Decidim::Plans::PlanSerializer)
    end
  end

  describe ".seed!" do
    let(:space) { component.participatory_space }

    before do
      # Create the admin user needed by the seeds
      create(
        :user,
        :confirmed,
        email: "admin@example.org",
        organization: component.organization
      )
    end

    it "actually seeds" do
      expect { component.manifest.seed!(space) }.not_to raise_error
    end
  end
end
