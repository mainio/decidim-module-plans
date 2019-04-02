# frozen_string_literal: true

require "spec_helper"

module Decidim::Plans
  describe TagsCell, type: :cell do
    controller Decidim::Plans::PlansController

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization: organization) }
    let(:component) { create(:plan_component, participatory_space: participatory_space) }
    let(:model) { plan }
    let(:user) { create :user, organization: organization }

    before do
      allow(controller).to receive(:current_user).and_return(user)
    end

    context "when a resource has no tags" do
      let(:plan) { create(:plan, :published) }

      it "doesn't render the tags of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).not_to have_css(".tags.tags--plan")
      end
    end

    context "when a resource has scope" do
      let(:scope) { create(:scope, organization: organization) }
      let(:plan) { create(:plan, :published, component: component, scope: scope) }

      it "renders the scope of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tags.tags--plan")
        expect(html).to have_content(translated(scope.name))
      end
    end

    context "when a resource has subscope" do
      let(:scope) { create(:scope, organization: organization) }
      let(:subscope) { create(:scope, organization: organization, parent: scope) }
      let(:plan) { create(:plan, :published, component: component, scope: subscope) }

      it "renders the subscope of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tags.tags--plan")
        expect(html).to have_content(translated(subscope.name))
      end
    end

    context "when a resource has category" do
      let(:category) { create(:category, participatory_space: participatory_space) }
      let(:plan) { create(:plan, :published, component: component, category: category) }

      it "renders the category of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tags.tags--plan")
        expect(html).to have_content(translated(category.name))
      end
    end

    context "when a resource has subcategory" do
      let(:category) { create(:category, participatory_space: participatory_space) }
      let(:subcategory) { create(:category, participatory_space: participatory_space, parent: category) }
      let(:plan) { create(:plan, :published, component: component, category: subcategory) }

      it "renders the subcategory of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tags.tags--plan")
        expect(html).to have_content(translated(subcategory.name))
      end
    end

    context "when a resource has taggings" do
      let(:tags) { create_list(:tag, 5, organization: organization) }
      let(:plan) { create(:plan, :published, component: component, tags: tags) }

      it "renders the taggings of the model" do
        html = cell("decidim/plans/tags", model, context: { extra_classes: ["tags--plan"] }).call
        expect(html).to have_css(".tags.tags--plan")
        tags.each do |tag|
          expect(html).to have_content(translated(tag.name))
        end
      end
    end

    context "when a resource has scope, category and taggings" do
      let(:scope) { create(:scope, organization: organization) }
      let(:category) { create(:category, participatory_space: participatory_space) }
      let(:tags) { create_list(:tag, 5, organization: organization) }
      let(:plan) { create(:plan, :published, component: component, scope: scope, category: category, tags: tags) }

      it "renders the scope and category of the model" do
        html = cell("decidim/plans/tags", plan, context: { extra_classes: ["tags--plan"] }).call

        expect(html).to have_css(".tags.tags--plan")
        expect(html).to have_content(translated(scope.name))
        expect(html).to have_content(translated(category.name))
        tags.each do |tag|
          expect(html).to have_content(translated(tag.name))
        end
      end
    end
  end
end
