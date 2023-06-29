# frozen_string_literal: true

base_path = File.expand_path("..", __dir__)

# Register the additonal path for Webpacker in order to make the module's
# stylesheets available for inclusion.
#
# Prepend needed due to overriding core map assets, see:
# https://github.com/decidim/decidim/pull/11105
Decidim::Webpacker.register_path("#{base_path}/app/packs", prepend: true)

# Register the entrypoints for your module. These entrypoints can be included
# within your application using `javascript_pack_tag` and if you include any
# SCSS files within the entrypoints, they become available for inclusion using
# `stylesheet_pack_tag`.
Decidim::Webpacker.register_entrypoints(
  decidim_plans: "#{base_path}/app/packs/entrypoints/decidim_plans.js",
  decidim_plans_data_picker: "#{base_path}/app/packs/entrypoints/decidim_plans_data_picker.js",
  decidim_plans_map: "#{base_path}/app/packs/entrypoints/decidim_plans_map.js",
  decidim_plans_plans_form: "#{base_path}/app/packs/entrypoints/decidim_plans_plans_form.js",
  decidim_plans_plans_list: "#{base_path}/app/packs/entrypoints/decidim_plans_plans_list.js",
  decidim_plans_proposal_picker: "#{base_path}/app/packs/entrypoints/decidim_plans_proposal_picker.js",
  decidim_plans_admin_authors: "#{base_path}/app/packs/entrypoints/decidim_plans_admin_authors.js",
  decidim_plans_admin_budgets_export: "#{base_path}/app/packs/entrypoints/decidim_plans_admin_budgets_export.js",
  decidim_plans_admin_component_settings: "#{base_path}/app/packs/entrypoints/decidim_plans_admin_component_settings.js",
  decidim_plans_admin_plan_picker: "#{base_path}/app/packs/entrypoints/decidim_plans_admin_plan_picker.js",
  decidim_plans_admin_sections: "#{base_path}/app/packs/entrypoints/decidim_plans_admin_sections.js"
)

# Register the main application's stylesheet include statement
Decidim::Webpacker.register_stylesheet_import("stylesheets/decidim/plans/plans")
