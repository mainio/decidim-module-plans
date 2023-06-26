# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::CellsHelper do
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

  describe "#withdrawable?" do
    let(:ctx) { double }
    let(:current_user) { double }

    it "calls from_context.withdrawable_by? if conditions are met" do
      return_value = true
      expect(helper).to receive(:from_context).and_return(ctx).twice
      allow(helper).to receive(:plans_controller?).and_return(true)
      allow(helper).to receive(:index_action?).and_return(false)
      allow(helper).to receive(:current_user).and_return(current_user)
      allow(ctx).to receive(:withdrawable_by?).with(current_user).and_return(return_value)
      expect(helper.withdrawable?).to be(return_value)
    end

    it "returns nil if no from_context" do
      allow(helper).to receive(:from_context).and_return(nil)
      expect(helper).not_to receive(:plans_controller?)
      expect(helper).not_to receive(:index_action?)
      expect(helper).not_to receive(:current_user)
      expect(helper.withdrawable?).to be(nil)
    end

    it "returns nil if not plans controller" do
      allow(helper).to receive(:from_context).and_return(ctx)
      allow(helper).to receive(:plans_controller?).and_return(false)
      expect(helper).not_to receive(:index_action?)
      expect(helper).not_to receive(:current_user)
      expect(helper.withdrawable?).to be(nil)
    end

    it "returns nil if index action" do
      allow(helper).to receive(:from_context).and_return(ctx)
      allow(helper).to receive(:plans_controller?).and_return(true)
      allow(helper).to receive(:index_action?).and_return(true)
      expect(helper).not_to receive(:current_user)
      expect(helper.withdrawable?).to be(nil)
    end
  end

  describe "#flaggable?" do
    let(:ctx) { double }
    let(:current_user) { double }

    it "returns true if conditions are met" do
      allow(helper).to receive(:from_context).and_return(ctx).twice
      allow(helper).to receive(:plans_controller?).and_return(true)
      allow(helper).to receive(:index_action?).and_return(false)
      expect(helper.flaggable?).to be(true)
    end

    it "returns nil if no from_context" do
      allow(helper).to receive(:from_context).and_return(nil)
      expect(helper).not_to receive(:plans_controller?)
      expect(helper).not_to receive(:index_action?)
      expect(helper.flaggable?).to be(nil)
    end

    it "returns nil if not plans controller" do
      allow(helper).to receive(:from_context).and_return(ctx)
      allow(helper).to receive(:plans_controller?).and_return(false)
      expect(helper).not_to receive(:index_action?)
      expect(helper.flaggable?).to be(nil)
    end

    it "returns nil if index action" do
      allow(helper).to receive(:from_context).and_return(ctx)
      allow(helper).to receive(:plans_controller?).and_return(true)
      allow(helper).to receive(:index_action?).and_return(true)
      expect(helper.flaggable?).to be(nil)
    end

    it "returns nil if official context" do
      expect(helper).to receive(:from_context).and_return(ctx).twice
      allow(helper).to receive(:plans_controller?).and_return(true)
      allow(helper).to receive(:index_action?).and_return(false)
      allow(ctx).to receive(:official?).and_return(true)
      expect(helper.flaggable?).to be(nil)
    end
  end
end
