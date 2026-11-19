# frozen_string_literal: true

require "spec_helper"

describe "ExportPlansToBudgets" do
  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:participatory_space) { create(:participatory_process, organization:) }
  let(:component) { create(:plan_component, participatory_space:) }
  let(:target_component) { create(:budgets_component, participatory_space:) }
  let!(:budget) { create(:budget, component: target_component) }
  let!(:section) { create(:section, :field_text, component:) }
  let!(:plans) { create_list(:plan, 3, :published, :accepted, closed_at: Time.current, component:, plan_proposals: []) }

  def decidim_admin_plans
    Decidim::EngineRouter.admin_proxy(component)
  end

  def visit_export_page
    visit decidim_admin_plans.plans_path(
      component_id: component.id,
      participatory_process_slug: participatory_space.slug
    )
    click_on "Convert to projects"
  end

  def fill_export_form
    select target_component.name["en"], from: "budgets_export_target_component_id"
    find(
      "#component_#{target_component.id}_budgets_export_target_details_#{target_component.id}_budget_id",
      visible: true
    )
    select translated(budget.title), from: "component_#{target_component.id}_budgets_export_target_details_#{target_component.id}_budget_id"
    check "budgets_export_content_sections_#{section.id}"
    fill_in "budgets_export_default_budget_amount", with: 50_000
    check "budgets_export_export_all_closed_plans"
  end

  before do
    switch_to_host(organization.host)
    sign_in user
  end

  context "when visiting the export page" do
    before { visit_export_page }

    it "renders the export form" do
      expect(page).to have_content("Convert to projects")
      expect(page).to have_select("budgets_export_target_component_id")
      expect(page).to have_button("Export to projects")
    end
  end

  context "when exporting without taxonomy filter" do
    before { visit_export_page }

    it "exports all accepted closed plans" do
      fill_export_form

      expect { click_on "Export to projects" }.to change(Decidim::Budgets::Project, :count).by(3)
      expect(page).to have_content("3 items successfully exported into budgeting projects.")
    end
  end

  context "when exporting with taxonomy filter" do
    let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
    let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
    let!(:taxonomy_filter) do
      create(
        :taxonomy_filter,
        root_taxonomy:,
        participatory_space_manifests: [participatory_space.manifest.name]
      )
    end
    let!(:filter_item) do
      create(:taxonomy_filter_item, taxonomy_filter:, taxonomy_item: taxonomy)
    end

    before do
      component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
      component.save!

      plans.first.taxonomizations.find_or_create_by(taxonomy:)
      plans.last.taxonomizations.find_or_create_by(taxonomy: other_taxonomy)

      visit_export_page
    end

    it "shows the taxonomy filter select" do
      expect(page).to have_css("#taxonomy_ids-#{taxonomy_filter.id}")
    end

    it "exports only plans with the selected taxonomy" do
      fill_export_form
      select translated(taxonomy.name), from: "taxonomy_ids-#{taxonomy_filter.id}"

      expect { click_on "Export to projects" }.to change(Decidim::Budgets::Project, :count).by(1)
      expect(page).to have_content("1 items successfully exported into budgeting projects.")

      project = Decidim::Budgets::Project.last
      expect(project.taxonomizations.pluck(:taxonomy_id)).to include(taxonomy.id)
    end

    it "exports all plans when no taxonomy is selected" do
      fill_export_form

      expect { click_on "Export to projects" }.to change(Decidim::Budgets::Project, :count).by(3)
      expect(page).to have_content("3 items successfully exported into budgeting projects.")
    end
  end
end
