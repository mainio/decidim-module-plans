# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AddAuthorsToPlan do
  let(:plan) { create(:plan, component: component, users: [current_user]) }
  let(:form_klass) { Decidim::Plans::AddAuthorToPlanForm }
  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:current_user) { create :user, :confirmed, organization: organization }
  let(:user) { create :user, :confirmed, organization: organization }
  let(:author) { create(:user, :confirmed, organization: organization) }
  let(:authors) { [user.id] }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(current_component: component)
  end
  let(:form_params) do
    { recipient_id: authors }
  end
  let(:command) { described_class.new(form, plan, current_user) }

  context "when authors are not available" do
    let(:authors) { [] }

    it "broadcasts invalid" do
      expect(command.call).to broadcast(:invalid)
    end
  end

  it "notify users" do
    expect(Decidim::EventsManager)
      .to receive(:publish)
      .with(
        event: "decidim.events.plans.plan_access_granted",
        event_class: Decidim::Plans::PlanAccessGrantedEvent,
        resource: plan,
        affected_users: [user]
      )
    command.call
  end

  it "adds authors and broadcasts ok" do
    expect(command.call).to broadcast(:ok, plan)
    expect(Decidim::Coauthorship.last.decidim_author_id).to eq(user.id)
  end
end
