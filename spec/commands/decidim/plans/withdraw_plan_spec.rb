# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe WithdrawPlan do
      let(:plan) { create(:plan) }

      before do
        plan.save!
      end

      describe "when current user IS the author of the plan" do
        let(:current_user) { plan.creator_author }
        let(:command) { described_class.new(plan, current_user) }

        context "and the plan has no supports" do
          it "withdraws the plan" do
            expect do
              expect { command.call }.to broadcast(:ok)
            end.to change { Decidim::Plans::Plan.count }.by(0)
            expect(plan.state).to eq("withdrawn")
          end
        end

        # context "and the plan HAS some supports" do
        #   before do
        #     plan.votes.create!(author: current_user)
        #   end
        #
        #   it "is not able to withdraw the plan" do
        #     expect do
        #       expect { command.call }.to broadcast(:invalid)
        #     end.to change { Decidim::Plans::Plan.count }.by(0)
        #     expect(plan.state).not_to eq("withdrawn")
        #   end
        # end
      end
    end
  end
end
