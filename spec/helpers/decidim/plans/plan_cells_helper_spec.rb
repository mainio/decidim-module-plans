# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanCellsHelper do
  describe "#has_actions?" do
    it "returns false" do
      expect(helper.has_actions?).to be(false)
    end
  end

  describe "#plans_controller?" do
    it "returns true for plans controller" do
      allow(helper).to receive(:context).and_return(
        controller: Decidim::Plans::PlansController.new
      )
      expect(helper.plans_controller?).to be(true)
    end

    it "returns false for other controller" do
      allow(helper).to receive(:context).and_return(
        controller: Decidim::PagesController.new
      )
      expect(helper.plans_controller?).to be(false)
    end
  end

  describe "#index_action?" do
    it "returns true for index actions" do
      allow(controller).to receive(:action_name).and_return("index")
      allow(helper).to receive(:context).and_return(
        controller: controller
      )
      expect(helper.index_action?).to be(true)
    end

    it "returns false for other actions" do
      allow(controller).to receive(:action_name).and_return("other")
      allow(helper).to receive(:context).and_return(
        controller: controller
      )
      expect(helper.index_action?).to be(false)
    end
  end

  describe "#current_settings" do
    let(:model) { double }
    let(:component) { double }
    let(:settings) { double }

    it "calls model.component.current_settings" do
      allow(model).to receive(:component).and_return(component)
      allow(component).to receive(:current_settings).and_return(settings)
      allow(helper).to receive(:model).and_return(model)
      expect(helper.current_settings).to be(settings)
    end
  end

  describe "#component_settings" do
    let(:model) { double }
    let(:component) { double }
    let(:settings) { double }

    it "calls model.component.current_settings" do
      allow(model).to receive(:component).and_return(component)
      allow(component).to receive(:settings).and_return(settings)
      allow(helper).to receive(:model).and_return(model)
      expect(helper.component_settings).to be(settings)
    end
  end

  describe "#current_component" do
    let(:model) { double }
    let(:component) { double }

    it "calls model.component.current_settings" do
      allow(model).to receive(:component).and_return(component)
      allow(helper).to receive(:model).and_return(model)
      expect(helper.current_component).to be(component)
    end
  end

  describe "#badge_name" do
    let(:state) { double }
    let(:name) { "Badge name" }

    it "calls humanize_plan_state with state" do
      allow(helper).to receive(:state).and_return(state)
      allow(helper).to receive(:humanize_plan_state).with(state).and_return(name)
      expect(helper.badge_name).to be(name)
    end
  end

  describe "#state_classes" do
    context "when accepted" do
      it "returns correct classes" do
        allow(helper).to receive(:state).and_return("accepted")
        expect(helper.state_classes).to match_array(["success"])
      end
    end

    context "when rejected" do
      it "returns correct classes" do
        allow(helper).to receive(:state).and_return("rejected")
        expect(helper.state_classes).to match_array(["alert"])
      end
    end

    context "when evaluating" do
      it "returns correct classes" do
        allow(helper).to receive(:state).and_return("evaluating")
        expect(helper.state_classes).to match_array(["warning"])
      end
    end

    context "when withdrawn" do
      it "returns correct classes" do
        allow(helper).to receive(:state).and_return("withdrawn")
        expect(helper.state_classes).to match_array(["alert"])
      end
    end

    context "when something else" do
      it "returns correct classes" do
        allow(helper).to receive(:state).and_return("something")
        expect(helper.state_classes).to match_array(["muted"])
      end
    end
  end
end
