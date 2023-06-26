# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe OfficialAuthorPresenter do
      describe "#name" do
        it "returns correct string" do
          expect(subject.name).to eq("Official proposal")
        end
      end

      describe "#nickname" do
        it "returns empty string" do
          expect(subject.nickname).to be_empty
        end
      end

      describe "#badge" do
        it "returns empty string" do
          expect(subject.badge).to be_empty
        end
      end

      describe "#profile_path" do
        it "returns empty string" do
          expect(subject.profile_path).to be_empty
        end
      end

      describe "#avatar_url" do
        it "calls the ActionController helpers" do
          expect(ActionController::Base.helpers).to receive(:asset_path).with(
            "decidim/default-avatar.svg"
          )
          subject.avatar_url
        end
      end

      describe "#deleted?" do
        it "returns false" do
          expect(subject.deleted?).to be(false)
        end
      end

      describe "#can_be_contacted?" do
        it "returns false" do
          expect(subject.can_be_contacted?).to be(false)
        end
      end

      describe "#has_tooltip?" do
        it "returns false" do
          expect(subject.has_tooltip?).to be(false)
        end
      end
    end
  end
end
