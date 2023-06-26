# frozen_string_literal: true

require "spec_helper"

module Decidim
  module ContentParsers
    describe PlanParser do
      let(:organization) { create(:organization) }
      let(:component) { create(:plan_component, organization: organization) }
      let(:context) { { current_organization: organization } }
      let!(:parser) { described_class.new(content, context) }

      describe "ContentParser#parse is invoked" do
        let(:content) { "" }

        it "must call PlanParser.parse" do
          expect(described_class).to receive(:new).with(content, context).and_return(parser)

          result = Decidim::ContentProcessor.parse(content, context)

          expect(result.rewrite).to eq ""
          expect(result.metadata[:plan].class).to eq Decidim::ContentParsers::PlanParser::Metadata
        end
      end

      describe "on parse" do
        subject { parser.rewrite }

        context "when content is nil" do
          let(:content) { nil }

          it { is_expected.to eq("") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([])
          end
        end

        context "when content is empty string" do
          let(:content) { "" }

          it { is_expected.to eq("") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([])
          end
        end

        context "when conent has no links" do
          let(:content) { "whatever content with @mentions and #hashes but no links." }

          it { is_expected.to eq(content) }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([])
          end
        end

        context "when content links to an organization different from current" do
          let(:plan) { create(:plan, component: component) }
          let(:external_plan) { create(:plan, component: create(:plan_component, organization: create(:organization))) }
          let(:content) do
            url = plan_url(external_plan)
            "This content references plan #{url}."
          end

          it "does not recognize the plan" do
            subject
            expect(parser.metadata.linked_plans).to eq([])
          end
        end

        context "when content has one link" do
          let(:plan) { create(:plan, component: component) }
          let(:content) do
            url = plan_url(plan)
            "This content references plan #{url}."
          end

          it { is_expected.to eq("This content references plan #{plan.to_global_id}.") }

          it "has metadata with the plan" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([plan.id])
          end
        end

        context "when content has one link that is a simple domain" do
          let(:link) { "aaa:bbb" }
          let(:content) do
            "This content contains #{link} which is not a URI."
          end

          it { is_expected.to eq(content) }

          it "has metadata with the plan" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to be_empty
          end
        end

        context "when content has many links" do
          let(:plan1) { create(:plan, component: component) }
          let(:plan2) { create(:plan, component: component) }
          let(:plan3) { create(:plan, component: component) }
          let(:content) do
            url1 = plan_url(plan1)
            url2 = plan_url(plan2)
            url3 = plan_url(plan3)
            "This content references the following plans: #{url1}, #{url2} and #{url3}. Great?I like them!"
          end

          it { is_expected.to eq("This content references the following plans: #{plan1.to_global_id}, #{plan2.to_global_id} and #{plan3.to_global_id}. Great?I like them!") }

          it "has metadata with all linked plans" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([plan1.id, plan2.id, plan3.id])
          end
        end

        context "when content has a link that is not in a plans component" do
          let(:plan) { create(:plan, component: component) }
          let(:content) do
            url = plan_url(plan).sub(%r{/plans/}, "/something-else/")
            "This content references a non-plan with same ID as a plan #{url}."
          end

          it { is_expected.to eq(content) }

          it "has metadata with no reference to the plan" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to be_empty
          end
        end

        context "when content has words similar to links but not links" do
          let(:similars) do
            %w(AA:aaa AA:sss aa:aaa aa:sss aaa:sss aaaa:sss aa:ssss aaa:ssss)
          end
          let(:content) do
            "This content has similars to links: #{similars.join}. Great! Now are not treated as links"
          end

          it { is_expected.to eq(content) }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to be_empty
          end
        end

        context "when plan in content does not exist" do
          let(:plan) { create(:plan, component: component) }
          let(:url) { plan_url(plan) }
          let(:content) do
            plan.destroy
            "This content references plan #{url}."
          end

          it { is_expected.to eq("This content references plan #{url}.") }

          it "has empty metadata" do
            subject
            expect(parser.metadata).to be_a(Decidim::ContentParsers::PlanParser::Metadata)
            expect(parser.metadata.linked_plans).to eq([])
          end
        end
      end

      def plan_url(plan)
        Decidim::ResourceLocatorPresenter.new(plan).url
      end
    end
  end
end
