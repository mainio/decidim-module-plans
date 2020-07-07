# frozen_string_literal: true

require "spec_helper"
require "decidim/plans/test/type_context"
require "decidim/core/test/shared_examples/categorizable_interface_examples"
require "decidim/core/test/shared_examples/scopable_interface_examples"
require "decidim/core/test/shared_examples/attachable_interface_examples"
require "decidim/core/test/shared_examples/coauthorable_interface_examples"

module Decidim
  module Plans
    describe PlanType, type: :graphql do
      include_context "with a graphql type"
      let(:component) { create(:plan_component) }
      let(:model) { create(:plan, :published, component: component) }

      include_examples "categorizable interface"
      include_examples "scopable interface"
      include_examples "attachable interface"
      include_examples "plan coauthorable interface"

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the plan's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the plan's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "state" do
        let(:query) { "{ state }" }

        it "returns the plan's state" do
          expect(response["state"]).to eq(model.state)
        end
      end

      context "when is answered" do
        before do
          model.answer = { en: "Some answer" }
          model.answered_at = Time.current
          model.save!
        end

        describe "answer" do
          let(:query) { '{ answer { translation(locale:"en") } }' }

          it "returns the plan's answer" do
            expect(response["answer"]["translation"]).to eq(model.answer["en"])
          end
        end

        describe "answeredAt" do
          let(:query) { "{ answeredAt }" }

          it "returns when was this query answered at" do
            expect(response["answeredAt"]).to eq(model.answered_at.to_time.iso8601)
          end
        end
      end

      context "when is closed" do
        before do
          model.closed_at = Time.current
          model.save!
        end

        describe "closedAt" do
          let(:query) { "{ closedAt }" }

          it "returns when was this query answered at" do
            expect(response["closedAt"]).to eq(model.closed_at.to_time.iso8601)
          end
        end
      end

      describe "publishedAt" do
        let(:query) { "{ publishedAt }" }

        it "returns when was this query published at" do
          expect(response["publishedAt"]).to eq(model.published_at.to_time.iso8601)
        end
      end

      describe "sections" do
        let(:query) { "{ sections { id } }" }

        it "returns the plan sections" do
          model.sections.each do |section|
            expect(response["sections"]).to include("id" => section.id.to_s)
          end
        end
      end

      describe "contents" do
        let(:query) { "{ contents { id } }" }

        it "returns the plan sections" do
          model.contents.each do |content|
            expect(response["contents"]).to include("id" => content.id.to_s)
          end
        end
      end

      describe "traceability" do
        let!(:pt_was_enabled) { ::PaperTrail.enabled? }

        before do
          ::PaperTrail.enabled = true
          Decidim::Plans.tracer.trace!(model.creator_identity) do
            model.update!(title: generate_localized_title)
          end
        end

        after do
          ::PaperTrail.enabled = false unless pt_was_enabled
        end

        context "when field createdAt" do
          let(:query) { "{ versions { createdAt } }" }

          it "returns created_at field of the version to iso format" do
            dates = response["versions"].map { |version| version["createdAt"] }
            expect(dates).to include(*model.versions.map { |version| version.created_at.to_time.iso8601 })
          end
        end

        context "when field id" do
          let(:query) { "{ versions { id } }" }

          it "returns ID field of the version" do
            ids = response["versions"].map { |version| version["id"].to_i }
            expect(ids).to include(*model.versions.map(&:id))
          end
        end

        context "when field editor" do
          let(:query) { "{ versions { editor { name } } }" }

          it "returns editor field of the versions" do
            editors = response["versions"].map { |version| version["editor"]["name"] if version["editor"] }
            expect(editors).to include(*model.versions.map do |version|
              author = Decidim.traceability.version_editor(version)
              author.name if author
            end)
          end
        end

        context "when field changeset" do
          let(:query) { "{ versions { changeset } }" }

          it "returns changeset field of the versions" do
            changesets = response["versions"].map { |version| version["changeset"] }
            expect(changesets).to include(*model.versions.map(&:changeset))
          end
        end
      end
    end
  end
end
