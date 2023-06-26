# frozen_string_literal: true

require "spec_helper"
require "decidim/api/test/type_context"

module Decidim
  module Plans
    describe SectionType, type: :graphql do
      include_context "with a graphql class type"
      let(:component) { create(:plan_component) }
      let(:model) { create(:section) }

      describe "id" do
        let(:query) { "{ id }" }

        it "returns the section's id" do
          expect(response["id"]).to eq(model.id.to_s)
        end
      end

      describe "position" do
        let(:query) { "{ position }" }

        it "returns the section's position" do
          expect(response["position"]).to eq(model.position)
        end
      end

      describe "body" do
        let(:query) { '{ body { translation(locale:"en")}}' }

        it "returns the section's body" do
          expect(response["body"]["translation"]).to eq(model.body["en"])
        end
      end
    end
  end
end
