# frozen_string_literal: true

require "spec_helper"
require "decidim/plans/test/type_context"

module Decidim
  module Plans
    describe TraceVersionType, type: :graphql do
      include_context "with a graphql type"
      let(:component) { create(:plan_component) }
      let(:plan) { create(:plan, :published, component: component) }
      let(:model) { plan.versions.last }
      let!(:pt_was_enabled) { ::PaperTrail.enabled? }

      before do
        ::PaperTrail.enabled = true
        Decidim::Plans.tracer.trace!(plan.creator_identity) do
          plan.update!(title: generate_localized_title)
        end
      end

      after do
        ::PaperTrail.enabled = false unless pt_was_enabled
      end

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the version's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "createdAt" do
        let(:query) { "{ createdAt }" }

        it "returns when was this version created at" do
          expect(response["createdAt"]).to eq(model.created_at.to_time.iso8601)
        end
      end

      describe "editor" do
        let(:query) { "{ editor { name } }" }

        it "returns the version's editor" do
          author = Decidim.traceability.version_editor(model)
          expect(response["editor"]["name"]).to eq(author.name)
        end
      end

      describe "changeset" do
        let(:query) { "{ changeset }" }

        it "returns the version's changeset" do
          expect(response["changeset"]).to include(model.changeset)
        end
      end
    end
  end
end
