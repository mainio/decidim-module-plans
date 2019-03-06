# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PublishPlanEvent do
  let(:resource) { create :plan }
  let(:resource_title) { resource.title["en"] }
  let(:event_name) { "decidim.events.plans.plan_published" }

  include_context "when a simple event"
  it_behaves_like "a simple event"

  describe "email_subject" do
    it "is generated correctly" do
      expect(subject.email_subject).to eq("A user you're following has published a resource")
    end
  end

  describe "email_intro" do
    it "is generated correctly" do
      expect(subject.email_intro)
        .to eq("\"#{resource_title}\" has been published. You can see it here:")
    end
  end

  describe "email_outro" do
    it "is generated correctly" do
      expect(subject.email_outro)
        .to eq("You have received this notification because you are following the author of \"#{resource_title}\". You can unfollow it from the previous link.")
    end
  end

  describe "notification_title" do
    it "is generated correctly" do
      expect(subject.notification_title)
        .to include("<a href=\"#{resource_url}\">#{resource_title}</a> has been published.")
    end
  end

  context "when published for a space" do
    let(:event_name) { "decidim.events.plans.plan_published_for_space" }

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("A resource you're following has been published")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("\"#{resource_title}\" has been published. You can see it here:")
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
          .to include("<a href=\"#{resource_url}\">#{resource_title}</a> has been published.")
      end
    end
  end

  context "when published for proposal authors" do
    let(:event_name) { "decidim.events.plans.plan_published_for_proposals" }

    describe "email_subject" do
      it "is generated correctly" do
        expect(subject.email_subject).to eq("A proposal you have authored has been linked to new content")
      end
    end

    describe "email_intro" do
      it "is generated correctly" do
        expect(subject.email_intro)
          .to eq("A proposal you have authored has been linked to \"#{resource_title}\". You can see it here:")
      end
    end

    describe "email_outro" do
      it "is generated correctly" do
        expect(subject.email_outro)
          .to eq("You have received this notification because you are following \"#{resource_title}\" through the authored proposals. You can unfollow it from the previous link.")
      end
    end

    describe "notification_title" do
      it "is generated correctly" do
        expect(subject.notification_title)
          .to include("A proposal you have authored has been linked to <a href=\"#{resource_url}\">#{resource_title}</a>.")
      end
    end
  end
end
