# frozen_string_literal: true

require "spec_helper"

describe "AdminManageSections" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:plan_component, participatory_space:) }

  def decidim_admin_plans
    Decidim::EngineRouter.admin_proxy(component)
  end

  def visit_sections_page
    visit decidim_admin_plans.plans_path(
      component_id: component.id,
      participatory_process_slug: participatory_space.slug
    )
    click_on "Sections"
  end

  before do
    switch_to_host(organization.host)
    sign_in user
  end

  context "when visiting the sections page" do
    before { visit_sections_page }

    it "renders the sections form" do
      expect(page).to have_content("Sections")
      expect(page).to have_button("Add section")
      expect(page).to have_button("Save")
    end
  end

  context "when there are existing sections" do
    let!(:section) { create(:section, :field_text, component:, handle: "test_section") }

    before { visit_sections_page }

    it "lists the existing section with its handle" do
      expect(page).to have_field("sections[#{section.id}][handle]", with: "test_section")
    end

    it "updates a section handle successfully" do
      fill_in "sections[#{section.id}][handle]", with: "updated_handle"

      click_on "Save"
      expect(page).to have_content("Sections updated successfully.")
      expect(section.reload.handle).to eq("updated_handle")
    end

    it "can mark a section as mandatory" do
      check "sections[#{section.id}][mandatory]"

      click_on "Save"
      expect(page).to have_content("Sections updated successfully.")
      expect(section.reload.mandatory).to be(true)
    end

    it "can mark a section as searchable" do
      check "sections[#{section.id}][searchable]"

      click_on "Save"
      expect(page).to have_content("Sections updated successfully.")
      expect(section.reload.searchable).to be(true)
    end

    it "can change section visibility" do
      uncheck "sections[#{section.id}][visible_form]"

      click_on "Save"
      expect(page).to have_content("Sections updated successfully.")
      expect(section.reload.visible_form).to be(false)
    end

    it "shows an error when handle is cleared" do
      fill_in "sections[#{section.id}][handle]", with: ""

      click_on "Save"
      expect(page).to have_content("There are errors on the form, please correct them.")
    end
  end

  context "when adding a new section" do
    before { visit_sections_page }

    it "adds a new section" do
      click_on "Add section"

      within ".sections-list .plan-section:last-child" do
        # New section uses timestamp-based ID, find fields by label
        fill_in "Handle", with: "new_section_handle"
        find("input[name*='[body_en]']").fill_in with: "New test section"
      end

      expect { click_on "Save" }.to change(Decidim::Plans::Section, :count).by(1)
      expect(page).to have_content("Sections updated successfully.")

      new_section = Decidim::Plans::Section.last
      expect(new_section.handle).to eq("new_section_handle")
    end
  end

  context "when removing a section" do
    let!(:section) { create(:section, :field_text, component:, handle: "removable_section") }

    before { visit_sections_page }

    it "removes the section" do
      within ".sections-list" do
        click_on "Remove"
      end

      expect { click_on "Save" }.to change(Decidim::Plans::Section, :count).by(-1)
      expect(page).to have_content("Sections updated successfully.")
    end
  end

  context "when there are multiple sections" do
    let!(:section1) { create(:section, :field_text, component:, position: 0, handle: "section_one") }
    let!(:section2) { create(:section, :field_text, component:, position: 1, handle: "section_two") }

    before { visit_sections_page }

    it "lists all sections by their handles" do
      expect(page).to have_field("sections[#{section1.id}][handle]", with: "section_one")
      expect(page).to have_field("sections[#{section2.id}][handle]", with: "section_two")
    end

    it "can reorder sections using move up/down buttons" do
      within ".sections-list .plan-section:last-child" do
        click_on "Up"
      end

      click_on "Save"
      expect(page).to have_content("Sections updated successfully.")
      expect(section2.reload.position).to be < section1.reload.position
    end
  end

  context "when adding a field_taxonomy section" do
    before { visit_sections_page }

    it "adds a taxonomy section" do
      click_on "Add section"

      within ".sections-list .plan-section:last-child" do
        fill_in "Handle", with: "taxonomy_section_handle"
        find("input[name*='[body_en]']").fill_in with: "Taxonomy section"
        select "Field - Taxonomy", from: "Section type"
      end

      expect { click_on "Save" }.to change(Decidim::Plans::Section, :count).by(1)
      expect(page).to have_content("Sections updated successfully.")
      expect(Decidim::Plans::Section.last.section_type).to eq("field_taxonomy")
    end
  end

  def decidim_admin_plans
    Decidim::EngineRouter.admin_proxy(component)
  end

  def visit_sections_page
    visit decidim_admin_plans.plans_path(
      component_id: component.id,
      participatory_process_slug: participatory_space.slug
    )
    click_on "Sections"
  end
end
