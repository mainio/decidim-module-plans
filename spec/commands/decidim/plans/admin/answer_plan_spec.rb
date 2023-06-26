# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::AnswerPlan do
  let(:form_klass) { Decidim::Plans::Admin::PlanAnswerForm }

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

  let!(:plan) { create :plan, component: component }

  describe "call" do
    let(:form_params) do
      {
        state: "accepted",
        answer: { en: "The plan has been accepted." }
      }
    end

    let(:command) do
      described_class.new(form, plan)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't add the answer" do
        expect do
          command.call
        end.not_to change(plan, :answer)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "adds the answer" do
        expect do
          command.call
        end.to change(plan, :answer).and change(plan, :answered_at)
          .and change(plan, :closed_at)
      end
    end
  end
end
