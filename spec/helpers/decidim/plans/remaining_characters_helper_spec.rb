# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::RemainingCharactersHelper do
  describe "#remaining_characters" do
    let(:attribute) { :test }
    let(:characters) { 100 }

    context "when no block is given" do
      it "does not return anything" do
        expect(helper.remaining_characters(attribute, characters)).to be(nil)
      end
    end

    context "when block is given" do
      let(:field) { "<input type='text' name='test'>" }
      let(:remaining_characters) { "<span></span>" }

      context "with positive number of characters" do
        it "yields with correct args" do
          expect(helper).to receive(:capture) do |&block|
            block.call
            field
          end
          expect(helper).to receive(:render).with(
            "decidim/plans/shared/remaining_characters_container",
            remaining_characters_id: "test_remaining_characters"
          ).and_return(remaining_characters)

          expect do |block|
            expect(
              helper.remaining_characters(attribute, characters, &block)
            ).to eq(field + remaining_characters)
          end.to yield_with_args(
            maxlength: characters,
            data: { remaining_characters: "#test_remaining_characters" }
          )
        end
      end

      context "with zero characters" do
        let(:characters) { 0 }

        it "yields with correct args" do
          expect(helper).to receive(:capture) do |&block|
            block.call
            field
          end
          expect(helper).to receive(:render).with(
            "decidim/plans/shared/remaining_characters_container",
            remaining_characters_id: nil
          ).and_return(remaining_characters)

          expect do |block|
            expect(
              helper.remaining_characters(attribute, characters, &block)
            ).to eq(field + remaining_characters)
          end.to yield_with_args({})
        end
      end
    end
  end
end
