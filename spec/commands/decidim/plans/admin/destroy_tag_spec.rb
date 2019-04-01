# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::DestroyTag do
  let(:organization) { create(:organization) }
  let(:user) { create :user, :admin, :confirmed, organization: organization }

  let!(:tag) { create :tag, organization: organization }

  describe "call" do
    let(:command) { described_class.new(tag, user) }

    it "broadcasts ok" do
      expect { command.call }.to broadcast(:ok)
    end

    it "creates a new tag" do
      expect do
        command.call
      end.to change(Decidim::Plans::Tag, :count).by(-1)
    end

    it "traces the destroy" do
      expect(Decidim.traceability)
        .to receive(:perform_action!)
        .with(:delete, tag, user)
        .and_call_original

      expect { command.call }.to change(Decidim::ActionLog, :count)

      action_log = Decidim::ActionLog.last
      expect(action_log.resource_type).to eq("Decidim::Plans::Tag")
      expect(action_log.resource_id).to eq(tag.id)
      expect(action_log.action).to eq("delete")
    end
  end
end
