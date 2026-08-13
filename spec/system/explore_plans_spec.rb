# frozen_string_literal: true

require "spec_helper"

describe "ExplorePlans" do
  with_versioning do
    let(:component) { create(:plan_component, :with_creation_enabled) }
    let(:organization) { component.organization }
    let!(:user) { create(:user, :confirmed, :admin, organization:) }
    let!(:plans) { create_list(:plan, 10, component:) }
    let!(:evaluating) { create_list(:plan, 5, :evaluating, component:) }
    let!(:rejected) { create_list(:plan, 3, :rejected, component:) }
    let!(:withdrawn) { create_list(:plan, 2, :withdrawn, component:) }
    let!(:accepted) { create(:plan, :accepted, component:) }

    describe "index" do
      before do
        switch_to_host(organization.host)
        visit decidim_plan.plans_path
      end

      it "renders the index page" do
        expect(page).to have_content("Browse proposals")
        expect(page).to have_css("form.new_filter")
        expect(page).to have_css("input[type='checkbox'][value='accepted']", count: 1)
        expect(page).to have_css("input[type='checkbox'][value='rejected']", count: 1)
        expect(page).to have_css("input[type='checkbox'][value='evaluating']", count: 1)
        expect(page).to have_css("a.action-link", text: "Submit a proposal")
        expect(page).to have_link("Submit a proposal", href: decidim_plan.new_plan_path)
      end

      it "filters the plans" do
        expect(page).to have_content("Found 19 proposals")

        within "form.new_filter" do
          check "Evaluating"
          find("button[type='submit']").click # rubocop:disable Capybara/SpecificActions
        end

        expect(page).to have_content("Found 5 proposals", wait: 5)

        within "form.new_filter" do
          uncheck "Evaluating"
          check "Accepted"
          find("button[type='submit']").click # rubocop:disable Capybara/SpecificActions
        end

        expect(page).to have_content("Found 1 proposal", wait: 5)
      end

      it "searches through the plans" do
        within ".filters__section" do
          fill_in "Search", with: translated(accepted.title)
          within ".input-group-button" do
            find('svg[aria-label="Search"]').click
          end
          wait_a_bit
        end
        within "#plans" do
          plans = find_all(".column")
          expect(plans.count).to eq(1)
          expect(page).to have_css(".column#plan_#{accepted.id}")
        end
      end

      context "when a draft plan exist" do
        let!(:plan) { create(:plan, :open, component:, published_at: nil, users: [user]) }
        let!(:content) { create(:content, plan:) }

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
          click_on "Continue your proposal"
          fill_in "contents[#{plan.sections.first.id}][body_en]", with: "Update text"
          click_on "Preview"
          expect(page).to have_content("Version 2 (of 2)")
          within ".card__content" do
            click_on "Edit"
          end
          expect(page).to have_current_path(decidim_plan.edit_plan_path(plan.id))
        end
      end
    end

    describe "new plan" do
      let!(:section) { create(:section, component:, mandatory: true) }

      before do
        switch_to_host(organization.host)
        sign_in user
        visit decidim_plan.new_plan_path
      end

      context "when not signed in" do
        it "renders sign in" do
          find_by_id("trigger-dropdown-account").click
          click_on "Log out"
          expect(page).to have_content("Submit a proposal")
          expect(page).to have_content("You need to sign in before submitting a proposal")
          click_on "Sign in", match: :first
          expect(page).to have_content("Please log in")
          expect(page).to have_field("Email")
          expect(page).to have_field("Password")
        end
      end

      context "when signed in" do
        it "renders the page" do
          expect(page).to have_content("Submit a proposal")
          expect(page).to have_button("Save as draft")
          expect(page).to have_button("Preview")
          expect(page).to have_field("contents[#{section.id}][body_en]")
          expect(page).to have_link("Back to proposals list")
          click_on "Preview"
          expect(page).to have_content("Failed to create new content.")
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_on "Save as draft"
          expect(page).to have_content("Created successfully.")
          expect(page).to have_link("Delete draft")
          plan = Decidim::Plans::Plan.last
          content = Decidim::Plans::Content.last
          expect(translated(content.body)).to eq("Dummy text")
          expect(plan.state).to eq("open")
        end

        it "deletes the draft" do
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_on "Save as draft"
          plans = Decidim::Plans::Plan.all
          expect(plans.count).to eq(22)
          expect(page).to have_link("Delete draft")
          click_on "Delete draft"
          expect(page).to have_content("Are you sure you want to delete this draft?")
          click_on "OK"
          expect(page).to have_content("Deleted successfully.")
          expect(page).to have_current_path(decidim_plan.new_plan_path)
          expect(plans.reload.count).to eq(21)
        end

        it "previews the plan" do
          fill_in "contents[#{section.id}][body_en]", with: "Dummy text"
          click_on "Preview"
          created_plan = Decidim::Plans::Plan.last
          expect(page).to have_current_path(decidim_plan.preview_plan_path(created_plan.id))
          expect(page).to have_content("Your proposal has not yet been published")
          expect(page).to have_link("Go to proposals list", href: decidim_plan.plans_path)
          expect(page).to have_button("Publish")
          expect(page).to have_link("Modify", href: decidim_plan.edit_plan_path(created_plan.id))
          expect(page).to have_css("span", text: "Withdraw")
          expect(page).to have_content("Version 1 (of 1)")
          within ".card-data__item.authors_status" do
            expect(page).to have_content("1")
          end
        end
      end
    end

    describe "explore authors" do
      let!(:plan) { create(:plan, :open, component:, published_at: nil, users: [user]) }
      let!(:content) { create(:content, plan:) }
      let!(:user1) { create(:user, :confirmed, organization:) }

      before do
        sign_in user
        switch_to_host(organization.host)
        visit decidim_plan.plan_path(plan.id)
      end

      context "with unpublished plan" do
        it "does not show add authors button" do
          expect(page).to have_no_button("Add authors for proposal")
        end
      end

      context "with published plan" do
        let!(:plan) { create(:plan, :open, :published, component:, users: [user]) }

        it "show/edits authors" do
          expect(page).to have_button("Add authors for proposal")
          within ".card-data__item.authors_status" do
            expect(page).to have_content("1")
          end

          click_on "Add authors for proposal"
          expect(page).to have_content("Add authors for proposal")
          fill_in "add_plan_authors-ts-control", with: user1.name

          expect(page).to have_css(".ts-dropdown-content .option", minimum: 1, wait: 5)
          first_option = find(".ts-dropdown-content .option", match: :first)
          first_option.click
          click_on "Next"
          expect(page).to have_current_path(decidim_plan.add_authors_plan_path(plan.id))
          expect(page).to have_content("Add authors for proposal")
          expect(page).to have_link("Back to proposal", href: decidim_plan.plan_path(plan.id))
          within ".author__name--container" do
            expect(page).to have_content(user1.name)
          end
          expect(page).to have_button "Add authors"
          expect(page).to have_link("Cancel", href: decidim_plan.plan_path(plan.id))

          click_on "Add authors"
          expect(page).to have_content("Successfully added authors for the proposal.")
          expect(plan.reload.authors).to include(user1)
          expect(plan.authors.count).to eq(2)
        end

        it "withdraws the plan" do
          expect(page).to have_link("Withdraw")
          click_on "Withdraw"
          expect(page).to have_content("Are you sure you want to withdraw this proposal?")
          click_on "OK"
          expect(page).to have_content("Item withdrawn successfully.")
          expect(page).to have_current_path(decidim_plan.plan_path(plan.id))
          within "span.alert" do
            expect(page).to have_content("Withdrawn")
          end
          expect(page).to have_no_link("Withdraw proposal")
          expect(page).to have_no_content("Add authors for proposal")
          expect(plan.reload.state).to eq("withdrawn")
        end
      end
    end

    describe "explore versions" do
      let!(:plan) { create(:plan, :open, component:, published_at: nil, users: [user]) }
      let!(:content) { create(:content, plan:) }
      let!(:user1) { create(:user, :confirmed, organization:) }

      context "with different versions available" do
        before do
          sign_in user
          switch_to_host(organization.host)
          visit decidim_plan.edit_plan_path(plan.id)
          fill_in "contents[#{plan.sections.first.id}][body_en]", with: "Update text"
          click_on "Preview"
        end

        it "shows different versions" do
          expect(page).to have_content("Version 2 (of 2)")
          click_on "see other versions"
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
          click_on "Version 1"
          expect(page).to have_link("Show all versions", href: decidim_plan.plan_versions_path(plan.id))
          expect(page).to have_link("Back to proposal", href: decidim_plan.plan_path(plan.id))
          expect(page).to have_content("Changes at")
          within "h2.heading2" do
            expect(page).to have_content(translated(plan.title))
          end
          expect(page).to have_content("Open")
          expect(page).to have_content("State")
          within "#diff-for-title" do
            expect(page).to have_content("Title")
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
          expect(page).to have_select("diff-mode", with_options: ["Unified", "Side-by-side"])
          select "Unified", from: "diff-mode"
          click_on "Toggle view"
          select "Side-by-side", from: "diff-mode"
          click_on "Toggle view"

          expect(page).to have_content(translated(plan.title))
          expect(page).to have_content("Update text")
        end
      end
    end

    describe "plan with taxonomy" do
      let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
      let(:parent_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
      let(:taxonomy) { create(:taxonomy, parent: parent_taxonomy, organization:, skip_injection: true) }
      let!(:taxonomy_filter) do
        create(
          :taxonomy_filter,
          root_taxonomy:,
          participatory_space_manifests: [component.participatory_space.manifest.name]
        )
      end
      let!(:parent_filter_item) do
        create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: parent_taxonomy)
      end
      let!(:child_filter_item) do
        create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy)
      end
      let!(:section) { create(:section, component:, mandatory: true) }
      let!(:taxonomy_section) { create(:section, :field_taxonomy, component:) }

      before do
        component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
        component.save!

        switch_to_host(organization.host)
        sign_in user
        visit decidim_plan.new_plan_path
      end

      it "selects a taxonomy and saves it with the plan" do
        fill_in "contents[#{section.id}][body_en]", with: "Dummy text"

        select translated(parent_taxonomy.name), from: "taxonomy_filter_#{taxonomy_filter.id}_#{taxonomy_section.id}"
        expect(page).to have_select("sub_taxonomy_select_#{parent_taxonomy.id}_#{taxonomy_section.id}")

        select translated(taxonomy.name), from: "sub_taxonomy_select_#{parent_taxonomy.id}_#{taxonomy_section.id}"

        click_on "Save as draft"
        expect(page).to have_content("Created successfully.")

        plan = Decidim::Plans::Plan.last
        content = plan.contents.find_by(section: taxonomy_section)

        expect(content.body["taxonomy_ids"]).to contain_exactly(parent_taxonomy.id, taxonomy.id)
        expect(plan.taxonomizations.count).to eq(2)
        expect(plan.taxonomizations.pluck(:taxonomy_id)).to contain_exactly(parent_taxonomy.id, taxonomy.id)
      end

      context "when updating plan with taxonomy" do
        let!(:plan) { create(:plan, :open, component:, published_at: nil, users: [user]) }
        let!(:text_content) { create(:content, section:, plan:, body: { en: "Existing text" }) }
        let!(:taxonomy_content) do
          create(:content, section: taxonomy_section, plan:, body: { "taxonomy_ids" => [parent_taxonomy.id, taxonomy.id] })
        end

        before do
          component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
          component.save!

          plan.taxonomizations.find_or_create_by(taxonomy_id: parent_taxonomy.id)
          plan.taxonomizations.find_or_create_by(taxonomy_id: taxonomy.id)

          switch_to_host(organization.host)
          sign_in user
          visit decidim_plan.edit_plan_path(plan.id)
        end

        it "pre-populates the parent select and reveals the sub-taxonomy select with the correct value" do
          parent_select = find("select##{"taxonomy_filter_#{taxonomy_filter.id}_#{taxonomy_section.id}"}")
          expect(parent_select.value).to eq(parent_taxonomy.id.to_s)

          sub_select_id = "sub_taxonomy_select_#{parent_taxonomy.id}_#{taxonomy_section.id}"
          expect(page).to have_select(sub_select_id)

          sub_div = find("#sub_taxonomy_#{parent_taxonomy.id}")
          expect(sub_div[:class]).not_to include("hide")
          expect(sub_div[:class]).not_to include("hidden")

          sub_select = find("select##{sub_select_id}")
          expect(sub_select.value).to eq(taxonomy.id.to_s)
        end

        it "allows changing the sub-taxonomy and persists the new selection" do
          other_taxonomy = create(:taxonomy, parent: parent_taxonomy, organization:, skip_injection: true)
          create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: other_taxonomy)

          visit decidim_plan.edit_plan_path(plan.id)

          sub_select_id = "sub_taxonomy_select_#{parent_taxonomy.id}_#{taxonomy_section.id}"
          select translated(other_taxonomy.name), from: sub_select_id

          click_on "Save as draft"
          expect(page).to have_content("saved successfully").or have_content("Updated successfully")

          content = plan.contents.reload.find_by(section: taxonomy_section)
          expect(content.body["taxonomy_ids"]).to contain_exactly(parent_taxonomy.id, other_taxonomy.id)
        end
      end
    end

    private

    def decidim_plan
      Decidim::EngineRouter.main_proxy(component)
    end

    def choose_filter(option)
      within ".filters__section" do
        choose option
      end
    end

    def wait_a_bit
      sleep(2)
    end
  end
end
