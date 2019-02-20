# frozen_string_literal: true

shared_examples "a plan form" do |options|
  subject { form }

  let(:organization) { create(:organization, available_locales: [:en]) }
  let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization) }
  let(:component) { create(:plan_component, participatory_space: participatory_space) }
  let(:proposal_component) { create(:proposal_component, participatory_space: participatory_space) }
  let(:title) { { en: "A reasonable plan title" } }
  let(:author) { create(:user, organization: organization) }
  let(:proposal_ids) { [create(:proposal, component: proposal_component).id] }
  let(:user_group) { create(:user_group, :verified, users: [author], organization: organization) }
  let(:user_group_id) { user_group.id }
  let(:category) { create(:category, participatory_space: participatory_space) }
  let(:scope) { create(:scope, organization: organization) }
  let(:category_id) { category.try(:id) }
  let(:scope_id) { scope.try(:id) }
  let(:attachment_params) { nil }
  let(:params) do
    {
      proposal_ids: proposal_ids,
      title: title,
      author: author,
      category_id: category_id,
      scope_id: scope_id,
      attachments: attachment_params.nil? ? nil : [attachment_params]
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

  context "when proposal linking is not enabled" do
    let(:component) { create(:plan_component, :with_proposal_linking_disabled, participatory_space: participatory_space) }

    context "with no proposals linked" do
      let(:proposal_ids) { nil }

      it { is_expected.to be_valid }
    end
  end

  context "when there's no title" do
    let(:title) { nil }

    it { is_expected.to be_invalid }

    it "only adds errors to this field" do
      subject.valid?
      expect(subject.errors.keys).to eq [:title_en]
    end
  end

  context "when no category_id" do
    let(:category_id) { nil }

    it { is_expected.to be_valid }
  end

  context "when no scope_id" do
    let(:scope_id) { nil }

    it { is_expected.to be_valid }
  end

  context "with invalid category_id" do
    let(:category_id) { 987 }

    it { is_expected.to be_invalid }
  end

  context "with invalid scope_id" do
    let(:scope_id) { 987 }

    it { is_expected.to be_invalid }
  end

  describe "category" do
    subject { form.category }

    context "when the category exists" do
      it { is_expected.to be_kind_of(Decidim::Category) }
    end

    context "when the category does not exist" do
      let(:category_id) { 7654 }

      it { is_expected.to eq(nil) }
    end

    context "when the category is from another process" do
      let(:category_id) { create(:category).id }

      it { is_expected.to eq(nil) }
    end
  end

  describe "scope" do
    subject { form.scope }

    context "when the scope exists" do
      it { is_expected.to be_kind_of(Decidim::Scope) }
    end

    context "when the scope does not exist" do
      let(:scope_id) { 3456 }

      it { is_expected.to eq(nil) }
    end

    context "when the scope is from another organization" do
      let(:scope_id) { create(:scope).id }

      it { is_expected.to eq(nil) }
    end

    context "when the participatory space has a scope" do
      let(:parent_scope) { create(:scope, organization: organization) }
      let(:participatory_space) { create(:participatory_process, :with_steps, organization: organization, scope: parent_scope) }
      let(:scope) { create(:scope, organization: organization, parent: parent_scope) }

      context "when the scope is descendant from participatory space scope" do
        it { is_expected.to eq(scope) }
      end

      context "when the scope is not descendant from participatory space scope" do
        let(:scope) { create(:scope, organization: organization) }

        it { is_expected.to eq(scope) }

        it "makes the form invalid" do
          expect(form).to be_invalid
        end
      end
    end
  end

  it "properly maps category id from model" do
    plan = create(:plan, component: component, category: category)

    expect(described_class.from_model(plan).category_id).to eq(category_id)
  end

  if options && options[:user_group_check]
    it "properly maps user group id from model" do
      plan = create(:plan, component: component, users: [author], user_groups: [user_group])

      expect(described_class.from_model(plan).user_group_id).to eq(user_group_id)
    end
  end
end
