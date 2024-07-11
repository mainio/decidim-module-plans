# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::InfoController do
  routes { Decidim::Plans::Engine.routes }

  let(:component) { create(:plan_component) }
  let(:participatory_space) { component.participatory_space }
  let!(:plan) { create(:plan, component:) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = participatory_space
    request.env["decidim.current_component"] = component
  end

  it "raises error when section does not exist" do
    expect { get :show, params: { section: 123, component_id: component.id } }
      .to raise_error(ActionController::RoutingError)
  end

  context "with an available section" do
    let!(:section) { create(:section, :field_text, component:) }

    it "shows section" do
      expect { get :show, params: { section: section.id, component_id: component.id } }
        .not_to raise_error
      expect(response).to render_template(:show)
      puts translated(section.information).inspect
      expect(response.headers["X-Robots-Tag"]).to eq("none")
    end
  end
end
