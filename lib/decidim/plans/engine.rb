# frozen_string_literal: true

module Decidim
  module Plans
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Plans

      routes do
        resources :plans do
          get :search_proposals
          resource :plan_widget, only: :show, path: "embed"
          resources :versions, only: [:show, :index]
          member do
            get :preview
            post :publish
            post :close
            put :withdraw
            post :add_authors
            patch :add_authors, action: :add_authors_confirm
            post :request_access, controller: "plan_collaborator_requests"
            post :request_accept, controller: "plan_collaborator_requests"
            post :request_reject, controller: "plan_collaborator_requests"
          end
          collection do
            resources :info, only: [:show], param: :section
            resource :geocoding, only: [:create] do
              collection do
                post :reverse
              end
            end
          end
        end

        root to: "plans#index"
      end

      initializer "decidim_plans.assets" do |app|
        app.config.assets.precompile += %w(decidim_plans_manifest.js
                                           decidim_plans_manifest.css
                                           decidim/plans/identity_selector_dialog.js
                                           decidim/plans/decidim_plans_manifest.js
                                           decidim/plans/social_share.js
                                           decidim/plans/map.js
                                           decidim/plans/plans_list.js
                                           decidim/plans/add_author_dialog.js
                                           decidim/plans/proposal_picker.scss
                                           decidim/plans/social_share.css.scss
                                           decidim/plans/plans_form.scss)
      end

      initializer "decidim_plans.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/views") # for partials
      end

      initializer "decidim_plans.content_processors" do |_app|
        Decidim.configure do |config|
          config.content_processors += [:plan]
        end
      end

      initializer "decidim_plans.register_section_types" do
        registry = Decidim::Plans.section_types

        registry.register(:field_title) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_title"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldTitleForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Title"
        end
        registry.register(:field_text) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_text"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldTextForm"
        end
        registry.register(:field_text_multiline) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_text_multiline"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldTextForm"
        end
        registry.register(:field_number) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_number"
          type.display_cell = "decidim/plans/section_type_display/field_number"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldNumberForm"
        end
        registry.register(:field_checkbox) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_checkbox"
          type.display_cell = "decidim/plans/section_type_display/field_checkbox"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldCheckboxForm"
        end
        registry.register(:field_scope) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_scope"
          type.display_cell = "decidim/plans/section_type_display/field_scope"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldScopeForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Scope"
        end
        registry.register(:field_area_scope) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_area_scope"
          type.display_cell = "decidim/plans/section_type_display/field_scope"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldScopeForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Scope"
        end
        registry.register(:field_category) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_category"
          type.display_cell = "decidim/plans/section_type_display/field_category"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldCategoryForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Category"
        end
        registry.register(:field_map_point) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_map_point"
          type.display_cell = "decidim/plans/section_type_display/field_map_point"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldMapPointForm"
        end
        registry.register(:field_attachments) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_attachments"
          type.display_cell = "decidim/plans/section_type_display/field_attachments"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldAttachmentsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Attachments"
        end
        registry.register(:field_image_attachments) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_image_attachments"
          type.display_cell = "decidim/plans/section_type_display/field_image_attachments"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldAttachmentsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Attachments"
        end
        registry.register(:content) do |type|
          type.content_control_class_name = "Decidim::Plans::SectionControl::Content"
        end
      end

      initializer "decidim_plans.register_layouts" do
        registry = Decidim::Plans.layouts

        registry.register(:default) do |layout|
          layout.public_name_key = "decidim.plans.layouts.default"
        end
      end

      initializer "decidim_plans.register_api_fields" do
        # These are defined dynamically in order to show an example on how to
        # extend the field types from external modules.
        Decidim::Plans::ContentMutationAttributes.class_eval do
          argument(:text, ::Decidim::Plans::ContentMutation::FieldTextAttributes, required: false)
          argument(:number, ::Decidim::Plans::ContentMutation::FieldNumberAttributes, required: false)
          argument(:map_point, ::Decidim::Plans::ContentMutation::FieldMapPointAttributes, required: false)
          argument(:checkbox, ::Decidim::Plans::ContentMutation::FieldCheckboxAttributes, required: false)
          argument(:category, ::Decidim::Plans::ContentMutation::FieldCategoryAttributes, required: false)
          argument(:scope, ::Decidim::Plans::ContentMutation::FieldScopeAttributes, required: false)
          argument(:area_scope, ::Decidim::Plans::ContentMutation::FieldAreaScopeAttributes, required: false)
          argument(:attachments, ::Decidim::Plans::ContentMutation::FieldAttachmentsAttributes, required: false)
          argument(:images, ::Decidim::Plans::ContentMutation::FieldImageAttachmentsAttributes, required: false)
        end
      end

      initializer "decidim_plans.proposals_integration" do
        next unless Decidim.const_defined?("Proposals")

        Decidim::Plans::ContentMutationAttributes.class_eval do
          argument(:proposals, ::Decidim::Plans::ContentMutation::FieldProposalsAttributes, required: false)
        end
        Decidim::Plans::ResourceLinkSubject.class_eval do
          possible_types(Decidim::Proposals::ProposalType)
        end
        Decidim::Plans.section_types.register(:link_proposals) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/link_proposals"
          type.content_form_class_name = "Decidim::Plans::ContentData::LinkProposalsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::LinkProposals"
        end
      end
    end
  end
end
