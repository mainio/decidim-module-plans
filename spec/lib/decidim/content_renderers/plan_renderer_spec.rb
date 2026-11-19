# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentRenderers
    describe PlanRenderer do
      let!(:renderer) { described_class.new(content) }

      describe "on parse" do
        subject { renderer.render }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }
        end

        context "when conent has no gids" do
          let(:content) { "whatever content with @mentions and #hashes but no gids." }

          it { is_expected.to eq(content) }
        end

        context "when content has one gid" do
          let(:plan) { create(:plan) }
          let(:content) do
            "This content references plan #{plan.to_global_id}."
          end

          it { is_expected.to eq("This content references plan #{plan_as_html_link(plan)}.") }
        end

        context "when content has many links" do
          let(:first_plan) { create(:plan) }
          let(:second_plan) { create(:plan) }
          let(:third_plan) { create(:plan) }
          let(:content) do
            first_gid = first_plan.to_global_id
            second_gid = second_plan.to_global_id
            third_gid = third_plan.to_global_id
            "This content references the following plans: #{first_gid}, #{second_gid} and #{third_gid}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following plans: #{plan_as_html_link(first_plan)}, #{plan_as_html_link(second_plan)} and #{plan_as_html_link(third_plan)}. Great?I like them!") }
        end
      end

      def plan_url(plan)
        Decidim::ResourceLocatorPresenter.new(plan).path
      end

      def plan_title(plan)
        Decidim::Plans::PlanPresenter.new(plan).title
      end

      def plan_as_html_link(plan)
        href = plan_url(plan)
        title = plan_title(plan)
        %(<a href="#{href}">#{title}</a>)
      end
    end
  end
end
