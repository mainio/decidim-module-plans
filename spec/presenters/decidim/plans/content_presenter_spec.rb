# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe ContentPresenter do
      let(:subject) { described_class.new(content) }
      let(:plan) { create(:plan) }
      let(:content) { create(:content, plan: plan) }

      describe "#title" do
        it "returns title in current locale" do
          expect(subject.title).to eq(content.section.body["en"])
        end
      end

      describe "#body" do
        it "returns body in current locale" do
          expect(subject.body).to eq(content.body["en"])
        end
      end
    end
  end
end
