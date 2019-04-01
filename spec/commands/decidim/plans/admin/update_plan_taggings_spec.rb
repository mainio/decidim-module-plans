# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::UpdatePlanTaggings do
  let(:form_klass) { Decidim::Plans::Admin::TaggingsForm }

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  let(:tags_before) { create_list(:tag, 5, organization: organization) }
  let(:tags_after) { create_list(:tag, 5, organization: organization) }

  let!(:plan) { create :plan, component: component, tags: tags_before }

  describe "call" do
    let(:form_params) do
      {
        tags: tags_after.collect { |t| t.id }
      }
    end

    let(:command) do
      described_class.new(form, plan)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the taggings" do
        expect do
          command.call
        end.not_to change {
          Decidim::Plans::PlanTagging.where(
            plan: plan
          ).collect { |pt| pt.tag.id }
        }
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the taggings" do
        expect do
          command.call
        end.to change {
          Decidim::Plans::PlanTagging.where(
            plan: plan
          ).collect { |pt| pt.tag.id }
        }
      end

      context "with no tags before" do
        let(:tags_before) { [] }

        it "updates the taggings" do
          command.call

          expect(
            Decidim::Plans::PlanTagging.where(
              plan: plan
            ).collect { |pt| pt.tag.id }
          ).to match_array(tags_after.collect { |t| t.id })
        end
      end

      context "with no tags after" do
        let(:tags_after) { [] }

        it "updates the taggings" do
          command.call

          expect(
            Decidim::Plans::PlanTagging.where(
              plan: plan
            ).count
          ).to eq(0)
        end
      end
    end
  end
end
