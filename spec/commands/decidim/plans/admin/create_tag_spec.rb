# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::CreateTag do
  let(:form_klass) { Decidim::Plans::Admin::TagForm }

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  describe "call" do
    let(:form_params) do
      {
        name: { en: "A new tag" }
      }
    end

    let(:command) { described_class.new(form) }

    describe "when the form is not valid" do
      before do
        expect(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't create a tag" do
        expect do
          command.call
        end.not_to change(Decidim::Plans::Tag, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "creates a new tag" do
        expect do
          command.call
        end.to change(Decidim::Plans::Tag, :count).by(1)
      end
    end
  end
end
