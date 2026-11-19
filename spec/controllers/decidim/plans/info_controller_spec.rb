# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::InfoController do
  include_context "with full participatory process params"

  let(:component) { create(:plan_component) }
  let(:participatory_space) { component.participatory_space }
  let!(:plan) { create(:plan, component:) }

  before do
    request.env["decidim.current_organization"] = component.organization
    request.env["decidim.current_participatory_space"] = participatory_space
    request.env["decidim.current_component"] = component
  end

  it "raises error when section does not exist" do
    expect { get :show, params: params.merge(section: 123) }
      .to raise_error(ActionController::RoutingError)
  end

  context "with an available section" do
    let!(:section) { create(:section, :field_text, component:) }

    it "shows section" do
      expect { get :show, params: params.merge(section: section.id) }
        .not_to raise_error
      expect(response).to render_template(:show)

      expect(response.headers["X-Robots-Tag"]).to eq("none")
    end
  end
end
