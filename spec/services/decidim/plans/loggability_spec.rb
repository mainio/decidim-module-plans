# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Loggability do
      let(:component) { create(:plan_component) }
      let(:organization) { component.organization }
      let(:author) { create(:user, :confirmed, organization: organization) }
      let(:plan) { create(:plan, component: component) }
      let(:action) { "test" }

      it "logs the action" do
        expect(subject).to receive(:log).with(
          action,
          author,
          plan,
          {}
        )
        subject.perform_action!(action, plan, author)
      end
    end
  end
end
