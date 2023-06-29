# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::UserGroupHelper do
  let(:manager) { create(:user, :confirmed) }
  let(:group1) { create(:user_group, :confirmed, :verified, users: [manager]) }
  let(:group2) { create(:user_group, :confirmed, :verified, users: [manager]) }
  let(:group3) { create(:user_group, :confirmed, :verified, users: [manager]) }

  describe "#user_group_select_field" do
    let(:field_name) { :test }
    let(:form) { double }

    before do
      helper.instance_variable_set(:@form, form)
      expect(helper).to receive(:current_user).and_return(manager).twice
    end

    context "when no existing group id is available" do
      before do
        allow(form).to receive(:user_group_id).and_return(nil)
      end

      it "calls form.select with correct arguments" do
        expect(form).to receive(:select).with(
          field_name,
          a_collection_containing_exactly(
            [group1.name, group1.id],
            [group2.name, group2.id],
            [group3.name, group3.id]
          ),
          selected: nil,
          include_blank: manager.name
        )
        helper.user_group_select_field(form, field_name)
      end
    end

    context "when existing group id is available" do
      before do
        allow(form).to receive(:user_group_id).and_return(group1.id)
      end

      it "calls form.select with correct arguments" do
        expect(form).to receive(:select).with(
          field_name,
          a_collection_containing_exactly(
            [group1.name, group1.id],
            [group2.name, group2.id],
            [group3.name, group3.id]
          ),
          selected: group1.id,
          include_blank: manager.name
        )
        helper.user_group_select_field(form, field_name)
      end
    end
  end
end
