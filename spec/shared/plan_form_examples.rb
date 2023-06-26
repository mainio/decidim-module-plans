# frozen_string_literal: true

shared_examples "a plan form" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:plan_component, participatory_space: participatory_space) }
  let(:author) { create(:user, organization: organization) }
  let(:user_group) { create(:user_group, :verified, users: [author], organization: organization) }
  let(:user_group_id) { user_group.id }
  let(:params) do
    {
      author: author
    }
  end

  let(:form) do
    described_class.from_params(params).with_context(
      current_component: component,
      current_organization: component.organization,
      current_participatory_space: participatory_space
    )
  end

  context "when everything is OK" do
    it { is_expected.to be_valid }
  end

  if options && options[:user_group_check]
    it "properly maps user group id from model" do
      plan = create(:plan, component: component, users: [author], user_groups: [user_group])

      expect(described_class.from_model(plan).user_group_id).to eq(user_group_id)
    end
  end
end
