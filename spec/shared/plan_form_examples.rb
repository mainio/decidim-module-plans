# frozen_string_literal: true

shared_examples "a plan form" do
  subject { form }

  let(:organization) { create(:organization, tos_version: Time.current, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization:) }
  let(:component) { create(:plan_component, participatory_space:) }
  let(:author) { create(:user, :confirmed, organization:) }

  let(:params) do
    {
      author:
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
end
