# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Plan do
      subject { plan }

      let(:component) { build :plan_component }
      let(:organization) { component.participatory_space.organization }
      let(:plan) { create(:plan, component: component) }
      let(:coauthorable) { plan }

      include_examples "coauthorable"
      include_examples "has component"
      include_examples "has scope"
      include_examples "has category"
      include_examples "reportable"

      it { is_expected.to be_valid }
      it { is_expected.to be_versioned }

      context "when it has been accepted" do
        let(:plan) { build(:plan, :accepted) }

        it { is_expected.to be_answered }
        it { is_expected.to be_accepted }
      end

      context "when it has been rejected" do
        let(:plan) { build(:plan, :rejected) }

        it { is_expected.to be_answered }
        it { is_expected.to be_rejected }
      end

      describe "#users_to_notify_on_comment_created" do
        let!(:follows) { create_list(:follow, 3, followable: subject) }
        let(:followers) { follows.map(&:user) }

        it "returns the followers and the author" do
          expect(subject.users_to_notify_on_comment_created).to match_array(followers.concat([plan.creator.author]))
        end
      end

      describe "#editable_by?" do
        let(:author) { create(:user, organization: organization) }

        context "when user is author" do
          let(:plan) { create :plan, component: component, users: [author], updated_at: Time.current }

          it { is_expected.to be_editable_by(author) }

          context "when the plan has been linked to another one" do
            let(:plan) { create :plan, component: component, users: [author], updated_at: Time.current }
            let(:original_plan) do
              original_component = create(:plan_component, organization: organization, participatory_space: component.participatory_space)
              create(:plan, component: original_component)
            end

            before do
              plan.link_resources([original_plan], "copied_from_component")
            end

            it { is_expected.not_to be_editable_by(author) }
          end
        end

        context "when plan is from user group and user is admin" do
          let(:user_group) { create :user_group, :verified, users: [author], organization: author.organization }
          let(:plan) { create :plan, component: component, updated_at: Time.current, users: [author], user_groups: [user_group] }

          it { is_expected.to be_editable_by(author) }
        end

        context "when user is not the author" do
          let(:plan) { build :plan, component: component, updated_at: Time.current }

          it { is_expected.not_to be_editable_by(author) }
        end

        context "when plan is answered" do
          let(:plan) { build :plan, :with_answer, component: component, updated_at: Time.current, users: [author] }

          it { is_expected.not_to be_editable_by(author) }
        end
      end

      describe "#closed?" do
        context "when plan is closed" do
          let(:plan) { build :plan, closed_at: Time.current }

          it { expect(plan.closed?).to be(true) }
        end

        context "when plan is not closed" do
          let(:plan) { build :plan }

          it { expect(plan.closed?).to be(false) }
        end
      end

      describe "#withdrawn?" do
        context "when plan is withdrawn" do
          let(:plan) { build :plan, :withdrawn }

          it { is_expected.to be_withdrawn }
        end

        context "when plan is not withdrawn" do
          let(:plan) { build :plan }

          it { is_expected.not_to be_withdrawn }
        end
      end

      describe "#withdrawable_by" do
        let(:author) { create(:user, organization: organization) }

        context "when user is author" do
          let(:plan) { create :plan, component: component, users: [author], created_at: Time.current }

          it { is_expected.to be_withdrawable_by(author) }
        end

        context "when user is admin" do
          let(:admin) { build(:user, :admin, organization: organization) }
          let(:plan) { build :plan, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(admin) }
        end

        context "when user is not the author" do
          let(:someone_else) { build(:user, organization: organization) }
          let(:plan) { build :plan, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(someone_else) }
        end

        context "when plan is already withdrawn" do
          let(:plan) { build :plan, :withdrawn, component: component, users: [author], created_at: Time.current }

          it { is_expected.not_to be_withdrawable_by(author) }
        end

        context "when the plan has been linked to another one" do
          let(:plan) { create :plan, component: component, users: [author], created_at: Time.current }
          let(:original_plan) do
            original_component = create(:plan_component, organization: organization, participatory_space: component.participatory_space)
            create(:plan, component: original_component)
          end

          before do
            plan.link_resources([original_plan], "copied_from_component")
          end

          it { is_expected.not_to be_withdrawable_by(author) }
        end
      end

      it "has an association of contents" do
        create(:content, plan: subject, user: create(:user, organization: plan.component.organization))
        create(:content, plan: subject, user: create(:user, organization: plan.component.organization))
        expect(subject.reload.contents.count).to eq(2)
      end
    end
  end
end
