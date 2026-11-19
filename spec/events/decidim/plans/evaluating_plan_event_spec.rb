# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::EvaluatingPlanEvent do
  let(:resource) { create(:plan) }
  let(:resource_title) { resource.title["en"] }
  let(:event_name) { "decidim.events.plans.plan_evaluating" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A resource you're following is being evaluated")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("\"#{resource_title}\" is currently being evaluated. You can check for an answer in this page:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following \"#{resource_title}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("<a href=\"#{resource_url}\">#{resource_title}</a> is being evaluated")
    end
  end
end
