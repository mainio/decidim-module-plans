# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    describe Section do
      subject { section }

      let(:component) { create(:dummy_component) }
      let(:section) { build(:section, component: component) }

      it { is_expected.to be_valid }

      it "has an associated component" do
        expect(subject.component).to eq(component)
      end
    end
  end
end
