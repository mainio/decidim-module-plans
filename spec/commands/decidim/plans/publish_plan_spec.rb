# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PublishPlan do
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:state) { :unpublished }
  let(:author) { create(:user, :confirmed, organization:) }
  let(:non_author) { create(:user, :confirmed, organization:) }
  let(:plan) { create(:plan, state, component:, users: [author]) }

  describe "call" do
    context "when called by the author" do
      subject do
        described_class.new(plan, author)
      end

      it "broadcasts ok" do
        expect { subject.call }.to broadcast(:ok)
        expect(plan.published_at).not_to be_nil
      end

      it "publishes the expected events" do
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(
            event: "decidim.events.plans.plan_published_author",
            event_class: Decidim::Plans::PublishPlanEvent
          )
        )
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(
            event: "decidim.events.plans.plan_published",
            event_class: Decidim::Plans::PublishPlanEvent
          )
        )
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(
            event: "decidim.events.plans.plan_published",
            event_class: Decidim::Plans::PublishPlanEvent,
            extra: { participatory_space: true }
          )
        )
        expect(Decidim::EventsManager).to receive(:publish).with(
          hash_including(
            event: "decidim.events.plans.plan_published",
            event_class: Decidim::Plans::PublishPlanEvent,
            extra: { proposal_author: true }
          )
        )

        subject.call
      end

      shared_examples "default state and answer defined" do |options|
        let(:component) { create(:plan_component, :with_default_state, default_state: options[:state]) }

        it "creates a plan with #{options[:state]} state" do
          subject.call
          plan = Decidim::Plans::Plan.last

          case options[:state]
          when "accepted"
            expect(plan.accepted?).to be(true)
          when "rejected"
            expect(plan.rejected?).to be(true)
          when "evaluating"
            expect(plan.evaluating?).to be(true)
          end
          expect(plan.answer).to be_nil
        end

        context "when a default answer is specified with the #{options[:state]} state" do
          let(:component) do
            create(
              :plan_component,
              :with_default_state,
              default_state: options[:state],
              default_answer: {
                "en" => "Default plan answer"
              }
            )
          end

          it "sets the answer for the plan" do
            subject.call
            plan = Decidim::Plans::Plan.last

            case options[:state]
            when "accepted"
              expect(plan.accepted?).to be(true)
            when "rejected"
              expect(plan.rejected?).to be(true)
            when "evaluating"
              expect(plan.evaluating?).to be(true)
            end
            expect(plan.answer).to include(
              "en" => "Default plan answer"
            )
          end
        end
      end

      it_behaves_like "default state and answer defined", state: "accepted"
      it_behaves_like "default state and answer defined", state: "rejected"
      it_behaves_like "default state and answer defined", state: "evaluating"
    end

    context "when called by non-author" do
      subject do
        described_class.new(plan, non_author)
      end

      it "broadcasts invalid" do
        expect { subject.call }.to broadcast(:invalid)
      end
    end
  end
end
