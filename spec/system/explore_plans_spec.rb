# frozen_string_literal: true

require "spec_helper"

describe "explore plans", type: :system do
  with_versioning do
    let(:component) { create(:plan_component, :with_creation_enabled) }
    let(:organization) { component.organization }
    let(:user) { create(:user, :confirmed, :admin, organization: organization) }
    let!(:plans) { create_list(:plan, 10, component: component) }
    let!(:evaluating) { create_list(:plan, 5, :evaluating, component: component) }
    let!(:rejected) { create_list(:plan, 3, :rejected, component: component) }
    let!(:withdrawn) { create_list(:plan, 2, :withdrawn, component: component) }
    let!(:accepted) { create(:plan, :accepted, component: component) }

    describe "index" do
      before do
        switch_to_host(organization.host)
        visit decidim_plan.plans_path
      end

      it "renders the index page" do
        expect(page).to have_content("Browse proposals")
        expect(page).to have_css("form.new_filter")
        expect(page).to have_css("input[type='radio'][value='all']", count: 1)
        expect(page).to have_css("input[type='radio'][value='accepted']", count: 1)
        expect(page).to have_css("input[type='radio'][value='rejected']", count: 1)
        expect(page).to have_css("input[type='radio'][value='evaluating']", count: 1)
        expect(page).to have_css("a.action-link", text: "Submit a proposal")
        expect(page).to have_link("Submit a proposal", href: decidim_plan.new_plan_path)
      end

      it "filters the plans" do
        choose_filter("All")
        within "#plans .cards-list" do
          plans = find_all(".column")
          expect(plans.count).to eq(19)
        end

        choose_filter("Evaluating")
        wait_a_bit
        within "#plans" do
          plans = find_all(".column")
          expect(plans.count).to eq(5)
        end

        choose_filter("Accepted")
        within "#plans" do
          expect(page).to have_selector(".column#plan_#{accepted.id}")
        end

        click_link "See all withdrawn" do
          within "#plans" do
            plans = find_all(".column")
            expect(plans.count).to eq(2)
          end
          expect(page).to have_content(translated(withdrawn.first.title))
          expect(page).to have_content(translated(withdrawn.last.title))
        end
      end

      it "searches through the plans" do
        within ".filters" do
          fill_in "Search", with: translated(accepted.title)
          click_on "Search"
          wait_a_bit
        end
        within "#plans" do
          plans = find_all(".column")
          expect(plans.count).to eq(1)
          expect(page).to have_selector(".column#plan_#{accepted.id}")
        end
      end

      context "when a draft plan exist" do
        let!(:plan) { create(:plan, :open, component: component, published_at: nil, users: [user]) }
        let!(:content) { create(:content, plan: plan) }

        before do
          sign_in user
          visit current_path
        end

        it "shows link to the draf plan" do
          expect(page).to have_content("You have a proposal draft!")
          expect(page).to have_link("Continue your proposal", href: decidim_plan.edit_plan_path(plan.id))
        end

        it "adds the version" do
          expect(page).to have_link("Continue your proposal", href: decidim_plan.edit_plan_path(plan.id))
          click_link "Continue your proposal"
          fill_in "contents[#{plan.sections.first.id}][body_en]", with: "Update text"
          click_button "Preview"
          expect(page).to have_content("VERSION 2 (of 2)")
          click_link "Edit"
          expect(page).to have_current_path(decidim_plan.edit_plan_path(plan.id))
        end
      end
    end

    describe "new plan" do
      let!(:section) { create(:section, component: component, mandatory: true) }

      before do
        switch_to_host(organization.host)
        visit decidim_plan.new_plan_path
      end

      it "renders sign in" do
        expect(page).to have_content("Submit a proposal")
        expect(page).to have_content("You need to sign in before submitting a proposal")
        click_link("Sign in", match: :first)
        expect(page).to have_content("Please sign in")
        expect(page).to have_field("Email")
        expect(page).to have_field("Password")
      end

      context "when signed in" do
        before do
          sign_in user
          visit current_path
        end

        it "renders the page" do
          expect(page).to have_content("Submit a proposal")
          expect(page).to have_button("Save as draft")
          expect(page).to have_button("Preview")
          expect(page).to have_field("contents[#{section.id}][body_en]")
          expect(page).to have_link("Back to proposals list")
          click_button "Preview"
          expect(page).to have_content("There's an error in this field")
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_button "Save as draft"
          expect(page).to have_content("Created successfully.")
          expect(page).to have_link("Delete draft")
          plan = Decidim::Plans::Plan.last
          content = Decidim::Plans::Content.last
          expect(translated(content.body)).to eq("Dummy text")
          expect(plan.state).to eq("open")
        end

        it "deletes the draft" do
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_button "Save as draft"
          plans = Decidim::Plans::Plan.all
          expect(plans.count).to eq(22)
          expect(page).to have_link("Delete draft")
          click_link "Delete draft"
          expect(page).to have_content("Are you sure you want to delete this draft?")
          find(".button[aria-label='OK']").click
          expect(page).to have_content("Deleted successfully.")
          expect(page).to have_current_path(decidim_plan.new_plan_path)
          expect(plans.reload.count).to eq(21)
        end

        it "previews plan" do
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_button "Preview"
          created_plan = Decidim::Plans::Plan.last
          expect(page).to have_current_path(decidim_plan.preview_plan_path(created_plan.id))
          expect(page).to have_content("Your proposal has not yet been published")
          expect(page).to have_link("Go to proposals list", href: decidim_plan.plans_path)
          expect(page).to have_button("Publish")
          expect(page).to have_link("Modify", href: decidim_plan.edit_plan_path(created_plan.id))
          expect(page).to have_link("Withdraw proposal", href: decidim_plan.withdraw_plan_path(created_plan.id))
          expect(page).to have_content("VERSION 1 (of 1)")
          within ".card-data__item.authors_status" do
            expect(page).to have_content("1")
          end
        end
      end
    end

    describe "explore authors" do
      let!(:plan) { create(:plan, :open, component: component, published_at: nil, users: [user]) }
      let!(:content) { create(:content, plan: plan) }
      let!(:user1) { create(:user, :confirmed, organization: organization) }

      before do
        sign_in user
        switch_to_host(organization.host)
        visit decidim_plan.plan_path(plan.id)
      end

      context "with unpublished plan" do
        it "does not show add authors button" do
          expect(page).not_to have_button("Add authors for proposal")
        end
      end

      context "with published plan" do
        before do
          plan.update!(published_at: Time.current)
          visit current_path
        end

        it "show/edits authors" do
          expect(page).to have_button("Add authors for proposal")
          within ".card-data__item.authors_status" do
            expect(page).to have_content("1")
          end

          click_button "Add authors for proposal"
          expect(page).to have_content("Add authors for proposal")
          fill_in "Write the author's name or nickname", with: user1.name

          expect(page).to have_css("ul#autoComplete_list_1")
          first_option = page.find("#autoComplete_list_1 li:first-child")
          first_option.click
          click_button "Next"
          expect(page).to have_current_path(decidim_plan.add_authors_plan_path(plan.id))
          expect(page).to have_content("ADD AUTHORS FOR PROPOSAL")
          expect(page).to have_link("Back to proposal", href: decidim_plan.plan_path(plan.id))
          within ".author__name--container" do
            expect(page).to have_content(user1.name)
          end
          expect(page).to have_button "Add authors"
          expect(page).to have_link("Cancel", href: decidim_plan.plan_path(plan.id))

          click_button "Add authors"
          expect(page).to have_content("Successfully added authors for the proposal.")
          expect(plan.reload.authors).to include(user1)
          expect(plan.authors.count).to eq(2)
        end

        it "withdraws the plan" do
          expect(page).to have_link("Withdraw proposal")
          click_link "Withdraw proposal"
          expect(page).to have_content("Are you sure you want to withdraw this proposal?")
          find(".button[aria-label='OK']").click
          expect(page).to have_content("Item withdrawn successfully.")
          expect(page).to have_current_path(decidim_plan.plan_path(plan.id))
          within "span.alert.label.idea-status" do
            expect(page).to have_content("Withdrawn")
          end
          expect(page).not_to have_link("Withdraw proposal")
          expect(page).not_to have_content("ADD AUTHORS FOR PROPOSAL")
          expect(plan.reload.state).to eq("withdrawn")
        end
      end
    end

    describe "explore versions" do
      let!(:plan) { create(:plan, :open, component: component, published_at: nil, users: [user]) }
      let!(:content) { create(:content, plan: plan) }
      let!(:user1) { create(:user, :confirmed, organization: organization) }

      context "with different versions available" do
        before do
          sign_in user
          switch_to_host(organization.host)
          visit decidim_plan.edit_plan_path(plan.id)
          fill_in "contents[#{plan.sections.first.id}][body_en]", with: "Update text"
          click_button "Preview"
        end

        it "shows different versions" do
          expect(page).to have_content("VERSION 2 (of 2)")
          click_link "see other versions"
          expect(page).to have_current_path(decidim_plan.plan_versions_path(plan.id))
          expect(page).to have_content("Changes at")
          within ".card--list__item", match: :first do
            expect(page).to have_content("Version 1")
          end
          within all(".card--list__item").last do
            expect(page).to have_content("Version 2")
          end
          expect(page).to have_css("div.card--list__text", count: 2)
        end

        it "compares different versions" do
          visit decidim_plan.plan_versions_path(plan.id)
          expect(page).to have_link("Version 1", href: decidim_plan.plan_version_path(plan_id: plan.id, id: 1))
          expect(page).to have_link("Version 2", href: decidim_plan.plan_version_path(plan_id: plan.id, id: 2))
          click_link "Version 1"
          expect(page).to have_link("Show all versions", href: decidim_plan.plan_versions_path(plan.id))
          expect(page).to have_link("Back to proposal", href: decidim_plan.plan_path(plan.id))
          expect(page).to have_content("Changes at")
          within "h2.heading2" do
            expect(page).to have_content(translated(plan.title))
          end
          expect(page).to have_content("Open")
          expect(page).to have_content("STATE")
          within ".diff-for-title" do
            expect(page).to have_content("TITLE")
            expect(page).to have_content(translated(plan.title))
          end
          visit decidim_plan.plan_version_path(plan_id: plan.id, id: 2)
          within "li.ins" do
            expect(page).to have_content("Update text")
          end
          within "li.del" do
            expect(page).to have_content(translated(content.body))
          end
        end

        it "changes view mode" do
          visit decidim_plan.plan_version_path(plan_id: plan.id, id: 2)
          expect(page).to have_link("Unified", href: "#diffmode-chooser-menu")
          click_link "Unified"
          expect(page).to have_link("Side-by-side")
          click_link("Side-by-side")

          expect(page).to have_content(translated(plan.title))
          expect(page).to have_content("Update text")
        end
      end
    end

    private

    def decidim_plan
      Decidim::EngineRouter.main_proxy(component)
    end

    def choose_filter(option)
      within ".filters" do
        choose option
      end
    end

    def wait_a_bit
      sleep(2)
    end
  end
end
