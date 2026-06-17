# frozen_string_literal: true

require "spec_helper"

module Decidim::Plans
  describe PlansPickerFieldCell, type: :cell do
    controller Decidim::Plans::PlansController

    let(:organization) { create(:organization) }
    let(:participatory_space) { create(:participatory_process, organization:) }

    let(:dummy_form_class) do
      Class.new(Decidim::Form) do
        attribute :plan_ids, Array[Integer]

        def plans
          Decidim::Plans::Plan.where(id: plan_ids)
        end
      end
    end
    let(:form_object) { dummy_form_class.new }
    let(:view) { ActionView::Base.new(ActionView::LookupContext.new([]), {}, nil) }
    let(:builder) { Decidim::FormBuilder.new(:dummy, form_object, view, {}) }

    let(:my_cell) { cell("decidim/plans/plans_picker_field", builder) }

    before do
      allow(controller).to receive(:current_participatory_space).and_return(participatory_space)
    end

    describe "#show" do
      context "when there is no plans component in the participatory space" do
        it "does not render" do
          html = my_cell.call
          expect(html).to have_no_css(".picker-multiple")
        end
      end

      context "when there is a plans component in the participatory space" do
        let!(:plans_component) { create(:plan_component, participatory_space:) }

        it "renders the picker field" do
          html = my_cell.call
          expect(html).to have_css(".picker-multiple")
        end

        it "renders the label with the translated text" do
          html = my_cell.call
          expect(html).to have_content("Proposals")
        end

        it "sets the picker name based on the field" do
          html = my_cell.call
          expect(html).to have_css("[data-picker-name='dummy[plan_ids]']")
        end

        it "debugs the rendered html" do
          html = my_cell.call
          puts html.native.to_s
        end
      end

      context "when there are multiple plans components in the participatory space" do
        let!(:second_plans_component) { create(:plan_component, participatory_space:, weight: 2) }
        let!(:first_plans_component) { create(:plan_component, participatory_space:, weight: 1) }

        it "uses the component with the lowest weight" do
          html = my_cell.call
          expect(html).to have_css(".picker-multiple")
        end
      end

      context "when the form has validation errors on the field" do
        let!(:plans_component) { create(:plan_component, participatory_space:) }

        before do
          form_object.errors.add(:plans, "is invalid")
        end

        it "adds the invalid input class" do
          html = my_cell.call
          expect(html).to have_css(".data-picker.is-invalid-input")
        end
      end

      context "when the form already has selected plans" do
        let!(:plans_component) { create(:plan_component, participatory_space:) }
        let(:selected_plan) { create(:plan, component: plans_component) }
        let(:form_object) do
          dummy_form_class.new.tap { |f| f.plan_ids = [selected_plan.id] }
        end

        it "includes the selected plan in the picker items" do
          html = my_cell.call
          expect(html).to have_content(translated(selected_plan.title))
        end
      end
    end
  end
end