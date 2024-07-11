# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::GeocodingsController do
  routes { Decidim::Plans::Engine.routes }

  let(:component) { create(:plan_component, :with_creation_enabled) }
  let!(:user) { create(:user, :admin, :confirmed) }
  let(:latitude) { 40.1234 }
  let(:longitude) { 2.1234 }
  let(:address) { "Some address" }

  before do
    sign_in user, scope: :user
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = component.participatory_space
    request.env["decidim.current_component"] = component
  end

  describe "create" do
    context "when geocoding is not enabled" do
      before do
        allow(Decidim::Map).to receive(:geocoding).and_return(nil)
      end

      it "renders error json" do
        put :create, params: { address:, latitude:, longitude: }

        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json_response = response.parsed_body
        expect(json_response["success"]).to be_falsy
        expect(json_response["result"]).to eq({})
      end
    end

    context "when coordinates does not exist" do
      let!(:address) { "" }

      it "renders the unsuccess" do
        put :create, params: { address:, latitude:, longitude: }

        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")

        json_response = response.parsed_body
        expect(json_response["success"]).to be_falsy
        expect(json_response["result"]).to eq({})
      end
    end

    context "when coordinates exist" do
      before do
        stub_geocoding(address, [latitude, longitude])
      end

      it "renders the successful" do
        put :create, params: { address:, latitude:, longitude: }

        expect(response).to be_successful
        expect(response.content_type).to eq("application/json; charset=utf-8")
        json_response = response.parsed_body
        expect(json_response["success"]).to be_truthy
        expect(json_response["result"]).to eq({ "lat" => 40.1234, "lng" => 2.1234 })
      end
    end
  end
end
