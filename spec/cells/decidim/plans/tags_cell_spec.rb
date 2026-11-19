# frozen_string_literal: true

require "spec_helper"

module Decidim::Plans
  describe TagsCell, type: :cell do
    controller Decidim::Plans::PlansController

    let(:organization) { create(:organization, tos_version: Time.current) }
    let(:participatory_space) { create(:participatory_process, organization:) }
    let(:component) { create(:plan_component, participatory_space:) }
    let(:model) { plan }
    let(:user) { create(:user, organization:) }
    let(:skip_injection) { true }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when a resource has no tags" do
      let(:plan) { create(:plan, :published) }

      it "doesn't render the tags of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_no_css(".tag-container.tags--plan")
      end
    end

    context "when a resource has a taxonomy" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:, skip_injection:) }
      let(:plan) { create(:plan, :published, component:, taxonomies: [taxonomy]) }

      it "renders the taxonomy of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tag-container.tags--plan")
        expect(html).to have_content(translated(taxonomy.name))
      end
    end

    context "when a resource has multiple taxonomies" do
      let(:taxonomies) { create_list(:taxonomy, 2, :with_parent, organization:, skip_injection:) }
      let(:plan) { create(:plan, :published, component:, taxonomies:) }

      it "renders all the taxonomies of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tag-container.tags--plan")
        taxonomies.each do |taxonomy|
          expect(html).to have_content(translated(taxonomy.name))
        end
      end
    end

    context "when a resource has taggings" do
      let(:tags) { create_list(:tag, 5, organization:) }
      let(:plan) { create(:plan, :published, component:, tags:) }

      it "renders the taggings of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tag-container.tags--plan")
        expect(html).to have_content("Filter results for tags")
      end
    end

    context "when a resource has taxonomy and taggings" do
      let(:taxonomy) { create(:taxonomy, :with_parent, organization:, skip_injection:) }
      let(:tags) { create_list(:tag, 5, organization:) }
      let(:plan) { create(:plan, :published, component:, taxonomies: [taxonomy], tags:) }

      it "renders the taxonomy and taggings of the model" do
        html = cell("decidim/plans/tags", plan, context: { extra_classes: ["tags--plan"] }).call

        expect(html).to have_css(".tag-container.tags--plan")
        expect(html).to have_content(translated(taxonomy.name))
        expect(html).to have_content("Filter results for tags")
      end
    end
  end
end
