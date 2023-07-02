# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe PlanPresenter do
      subject { described_class.new(plan) }
      let(:plan) { create(:plan) }

      let(:component_id) { plan.component.id }
      let(:process_slug) { plan.component.participatory_space.slug }

      let(:malicious_content_array) do
        [
          "<script>alert('XSS');</script>",
          "<img src='https://www.decidim.org'>",
          "<a href='http://www.decidim.org'>Link</a>"
        ]
      end
      let(:malicious_content) { malicious_content_array.join("\n") }

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

        context "when title contains malicious HTML" do
          let(:plan) do
            create(
              :plan,
              title: Decidim::Faker::Localized.localized { malicious_content }
            )
          end

          it "sanitizes the HTML" do
            malicious_content_array.each do |mc|
              expect(subject.title).not_to include(mc)
            end
          end
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

        context "when body contains malicious HTML" do
          let(:section) do
            create(
              :section,
              component: plan.component,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end

          before do
            create(
              :content,
              plan: plan,
              section: section,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end

          it "sanitizes the HTML" do
            malicious_content_array.each do |mc|
              expect(subject.title).not_to include(mc)
            end
          end
        end
      end

      describe "#display_mention" do
        let(:title) { double }
        let(:plan_path) { double }

        it "returns body link to the plan" do
          allow(subject).to receive(:title).and_return(title)
          allow(subject).to receive(:plan_path).and_return(plan_path)
          expect(subject).to receive(:link_to).with(title, plan_path)

          subject.display_mention
        end
      end
    end
  end
end
