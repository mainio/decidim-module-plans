# frozen_string_literal: true

require "spec_helper"
require "decidim/plans/test/type_context"

module Decidim
  module Plans
    describe PlanMutationType do
      include_context "with a graphql type"

      let(:participatory_process) { create(:participatory_process, organization: current_organization) }
      let(:component) { create(:plan_component, participatory_space: participatory_process) }
      let(:model) { create(:plan, :published, component: component) }
      let(:state) { "accepted" }
      let(:answer_content) { "Answer in English" }

      describe "answer" do
        let(:query) do
          "{ answer(state: \"#{state}\", answerContent: {en: \"#{answer_content}\"} ) { state, answer { translation(locale: \"en\") } } }"
        end

        context "with a normal user" do
          it "does not update the plan" do
            expect { response }.to raise_error(::Decidim::Plans::ActionForbidden)
          end
        end

        context "with an admin user" do
          let!(:current_user) { create(:user, :confirmed, :admin, organization: current_organization) }

          it "calls Admin::AnswerPlan command" do
            answer_json = { "en" => answer_content }

            params = { "plan_answer" => { "state" => state, "answer" => answer_json } }
            context = {
              current_organization: current_organization,
              current_user: current_user
            }
            expect(Decidim::Plans::Admin::PlanAnswerForm).to receive(:from_params).with(params).and_call_original
            expect_any_instance_of(Decidim::Plans::Admin::PlanAnswerForm) # rubocop:disable RSpec/AnyInstance
              .to receive(:with_context).with(context).and_call_original
            expect(Decidim::Plans::Admin::AnswerPlan).to receive(:call).with(
              an_instance_of(Decidim::Plans::Admin::PlanAnswerForm),
              model
            ).and_call_original
            expect(response["answer"]).to include(
              "state" => state,
              "answer" => { "translation" => answer_content }
            )

            expect(model.state).to eq("accepted")
            expect(model.answer).to include("en" => answer_content)
          end
        end
      end
    end
  end
end
