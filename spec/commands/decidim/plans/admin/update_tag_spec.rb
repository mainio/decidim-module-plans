# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::UpdateTag do
  let(:form_klass) { Decidim::Plans::Admin::TagForm }

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

  let!(:tag) { create :tag, organization: organization }

  describe "call" do
    let(:form_params) do
      {
        name: { en: "A new tag" }
      }
    end

    let(:command) do
      described_class.new(form, tag)
    end

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the tag" do
        expect do
          command.call
        end.not_to change(tag, :name)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the tag" do
        expect do
          command.call
        end.to change(tag, :name)
      end

      it "traces the update", versioning: true do
        expect(Decidim.traceability)
          .to receive(:perform_action!)
          .with(:update, tag, user)
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.resource).to eq(tag)
        expect(action_log.action).to eq("update")
      end
    end
  end
end
