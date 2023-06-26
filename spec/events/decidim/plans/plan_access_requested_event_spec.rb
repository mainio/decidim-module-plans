# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanAccessRequestedEvent do
  include_context "when a simple event"

  let(:event_name) { "decidim.events.plans.plan_access_requested" }
  let(:resource) { create :plan }
  let(:resource_url) { Decidim::ResourceLocatorPresenter.new(resource).url }
  let(:resource_title) { resource.title["en"] }
  let(:author) { resource.authors.first }
  let(:author_id) { author.id }
  let(:author_presenter) { Decidim::UserPresenter.new(author) }
  let(:author_path) { author_presenter.profile_path }
  let(:author_name) { author_presenter.name }
  let(:author_nickname) { author_presenter.nickname }
  let(:requester) { create :user, :confirmed, organization: resource.organization }
  let(:requester_name) { requester.name }
  let(:requester_id) { requester.id }
  let(:requester_presenter) { Decidim::UserPresenter.new(requester) }
  let(:requester_path) { requester_presenter.profile_path }
  let(:requester_nickname) { requester_presenter.nickname }
  let(:extra) { { requester_id: requester_id } }

  context "when the notification is for coauthor users" do
    it_behaves_like "a simple event"

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("#{requester_name} requested access to contribute to #{resource_title}.")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq(%(#{requester_name} requested contributor access. You can <strong>accept or reject the request</strong> from the <a href="#{resource_url}">#{resource_title}</a> page.))
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq(%(You have received this notification because you are a collaborator in <a href="#{resource_url}">#{resource_title}</a>.))
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include(%(<a href="#{requester_path}">#{requester_name} #{requester_nickname}</a> requested access to contribute to <a href="#{resource_url}">#{resource_title}</a>. Please <strong>accept or reject the request</strong>.))
      end
    end
  end
end
