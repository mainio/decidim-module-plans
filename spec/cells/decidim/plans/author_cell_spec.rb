# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AuthorCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/author", model) }
  let(:model) { create(:user, :confirmed) }
  let(:current_user) { create(:user, :confirmed) }

  let!(:organization) { create(:organization, tos_version: Time.current) }
  let(:user) { create(:user, :confirmed, organization:) }
  let(:user_group) { create(:user_group, :confirmed, :verified) }
  let(:plan) { create(:plan) }

  controller Decidim::Plans::PlansController

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
    allow(controller).to receive(:current_user).and_return(current_user)
  end

  context "when rendering a user" do
    let(:model) { Decidim::UserPresenter.new(user) }

    it "renders a User author card" do
      expect(subject).to have_css(".author-data")
    end
  end

  context "when rendering a user group" do
    let(:model) { Decidim::UserGroupPresenter.new(user_group) }

    it "renders a User_group author card" do
      expect(subject).to have_css(".author-data")
    end
  end

  context "when has a plan context" do
    let(:model) { Decidim::UserPresenter.new(user) }
    let(:my_cell) { cell("decidim/plans/author", model, from: plan) }

    it "renders the flag button with report modal target" do
      expect(subject).to have_css("button[data-open='flagModal'][title='Report']")
    end

    context "when there's no current user" do
      let(:current_user) { nil }

      it "renders the flag button with login modal target" do
        expect(subject).to have_css("button[data-open='loginModal'][title='Report']")
      end
    end

    context "when is withdrawable" do
      before do
        allow(my_cell).to receive(:withdrawable?).and_return(true)
      end

      it "renders the withdraw button" do
        expect(subject).to have_css("a:contains('Withdraw')")
      end
    end
  end
end
