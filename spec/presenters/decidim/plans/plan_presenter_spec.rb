# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanPresenter do
      let(:subject) { described_class.new(plan) }
      let(:plan) { create(:plan) }

      let(:component_id) { plan.component.id }
      let(:process_slug) { plan.component.participatory_space.slug }

      describe "#author" do
        it "returns Decidim::UserPresenter" do
          expect(subject.author).to be_a(Decidim::UserPresenter)
        end
      end

      describe "#plan_path" do
        it "returns correct path" do
          expect(subject.plan_path).to eq(
            "/processes/#{process_slug}/f/#{component_id}/plans/#{plan.id}"
          )
        end
      end

      describe "#title" do
        it "returns title in current locale" do
          expect(subject.title).to eq(plan.title["en"])
        end
      end

      describe "#body" do
        it "returns body in current locale" do
          fields = plan.sections.map do |section|
            content = plan.contents.find_by(section: section)
            next if content.nil?

            title = translated_attribute(content.title)
            body = translated_attribute(content.body)
            "<dt>#{title}</dt> <dd>#{body}</dd>"
          end

          expect(subject.body).to eq("<dl>#{fields.join("\n")}</dl>")
        end
      end
    end
  end
end
