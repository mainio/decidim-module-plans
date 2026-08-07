# frozen_string_literal: true

require "spec_helper"

describe "AdminManagesAuthors" do
  include_context "when managing a component"

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :confirmed, :admin, organization:) }
  let(:user2) { create(:user, :confirmed, :admin, organization:) }
  let!(:plan) { create(:plan, component:, category:, users: [user, user2]) }
  let!(:authors) { create_list(:user, 5, :confirmed, organization:) }
  let(:author) { authors.first }
  let(:category) { create(:category, participatory_space: component.participatory_space) }
  let(:slug) { component.participatory_space.slug }

  describe "manage authors" do
    before do
      visit current_path
    end

    it "shows the plans" do
      within "table.table-list" do
        expect(page).to have_content(translated(plan.title))
        expect(page).to have_content(plan.id)
        expect(page).to have_content(translated(category.name))
        expect(page).to have_content("Not answered")
      end
    end

    it "removes the authors" do
      click_on "Manage authors"
      expect(plan.authors.count).to eq(2)
      expect(page).to have_current_path("/admin/participatory_processes/#{slug}/components/#{component.id}/manage/plans/#{plan.id}/authors")
      within "table.table-list tbody" do
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.nickname)
      end
      remove_author
      expect(page).to have_content("Successfully removed the author from the proposal.")
      remove_author
      expect(page).to have_content("There was an error removing the author from the proposal.")
      expect(plan.reload.authors.count).to eq(1)
    end

    it "adds authors" do
      click_on "Manage authors"
      click_on "Add author"
      expect(page).to have_content("Add authors for proposal")
      fill_in "add_plan_authors", with: author.name
      expect(page).to have_css("[id^='autoComplete_list'] li", minimum: 1, wait: 5)
      expect(page).to have_content(author.nickname)
      all("[id^='autoComplete_list'] li").last.click
      click_on "Next"
      expect(page).to have_content "Add authors for proposal"
      expect(page).to have_content "#{author.name} (@#{author.nickname})"
      expect(page).to have_button("Add authors")
      click_on "Add authors"
      expect(page).to have_current_path(%r{/plans/#{plan.id}/authors$})
      expect(page).to have_content("Successfully added authors for the proposal.")
      plan.reload
      expect(plan.authors).to include(author)
      expect(plan.authors.count).to eq(3)
      within "tbody" do
        expect(page).to have_content(author.name)
        expect(page).to have_content(author.nickname)
      end
    end
  end

  private

  def remove_author
    within all("tbody tr").first do
      click_on "Remove author"
    end
    expect(page).to have_content "Are you sure you want to delete this?"
    click_on "OK"
  end

  def decidim_plan
    Decidim::EngineRouter.admin_proxy(component)
  end
end
