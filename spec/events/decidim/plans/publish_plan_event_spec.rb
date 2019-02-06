# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PublishPlanEvent do
  let(:resource) { create :plan }
  let(:resource_title) { resource.title["en"] }
  let(:event_name) { "decidim.events.plans.plan_published_for_space" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A plan you're following has been published")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("The plan \"#{resource_title}\" has been published. You can see it here:")
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
        .to include("The <a href=\"#{resource_path}\">#{resource_title}</a> plan has been published.")
    end
  end
end
