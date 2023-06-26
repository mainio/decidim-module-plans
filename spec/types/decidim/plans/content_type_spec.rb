# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Plans
    describe ContentType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:plan_component) }
      let(:model) { create(:content) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the content's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "title" do
        let(:query) { '{ title { translation(locale:"en")}}' }

        it "returns the content's title" do
          expect(response["title"]["translation"]).to eq(model.title["en"])
        end
      end

      describe "body" do
        let(:query) { '{ body { translation(locale:"en")}}' }

        it "returns the content's body" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end
    end
  end
end
