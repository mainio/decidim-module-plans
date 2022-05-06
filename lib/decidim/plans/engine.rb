# frozen_string_literal: true

module Decidim
  module Plans
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Plans

      routes do
        resources :plans do
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
            delete :disjoin
          end
          collection do
            get :search_proposals
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
                                           decidim/plans/social_share.js
                                           decidim/plans/map.js
                                           decidim/plans/plans_list.js
                                           decidim/plans/data_picker.scss
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
          type.content_control_class_name = "Decidim::Plans::SectionControl::Text"
        end
        registry.register(:field_text_multiline) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_text_multiline"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldTextForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Text"
        end
        registry.register(:field_number) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_number"
          type.display_cell = "decidim/plans/section_type_display/field_number"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldNumberForm"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldNumberType"
        end
        registry.register(:field_currency) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_number"
          type.display_cell = "decidim/plans/section_type_display/field_number"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldNumberForm"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldCurrencyType"
        end
        registry.register(:field_checkbox) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_checkbox"
          type.display_cell = "decidim/plans/section_type_display/field_checkbox"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldCheckboxForm"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldCheckboxType"
        end
        registry.register(:field_scope) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_scope"
          type.display_cell = "decidim/plans/section_type_display/field_scope"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldScopeForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Scope"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldScopeType"
        end
        registry.register(:field_area_scope) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_area_scope"
          type.display_cell = "decidim/plans/section_type_display/field_scope"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldScopeForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Scope"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldAreaScopeType"
        end
        registry.register(:field_category) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_category"
          type.display_cell = "decidim/plans/section_type_display/field_category"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldCategoryForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Category"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldCategoryType"
        end
        registry.register(:field_tags) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_tags"
          type.display_cell = "decidim/plans/section_type_display/field_tags"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldTagsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Tags"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldTagsType"
        end
        registry.register(:field_map_point) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_map_point"
          type.display_cell = "decidim/plans/section_type_display/field_map_point"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldMapPointForm"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldMapPointType"
        end
        registry.register(:field_attachments) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_attachments"
          type.display_cell = "decidim/plans/section_type_display/field_attachments"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldAttachmentsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Attachments"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldAttachmentsType"
        end
        registry.register(:field_image_attachments) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/field_image_attachments"
          type.display_cell = "decidim/plans/section_type_display/field_image_attachments"
          type.content_form_class_name = "Decidim::Plans::ContentData::FieldImageAttachmentsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::Attachments"
          type.api_type_class_name = "Decidim::Plans::SectionContent::FieldImageAttachmentsType"
        end
        registry.register(:content) do |type|
          type.content_control_class_name = "Decidim::Plans::SectionControl::Content"
          type.api_type_class_name = "Decidim::Plans::SectionContent::ContentType"
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
          argument(:currency, ::Decidim::Plans::ContentMutation::FieldCurrencyAttributes, required: false)
          argument(:map_point, ::Decidim::Plans::ContentMutation::FieldMapPointAttributes, required: false)
          argument(:checkbox, ::Decidim::Plans::ContentMutation::FieldCheckboxAttributes, required: false)
          argument(:category, ::Decidim::Plans::ContentMutation::FieldCategoryAttributes, required: false)
          argument(:scope, ::Decidim::Plans::ContentMutation::FieldScopeAttributes, required: false)
          argument(:area_scope, ::Decidim::Plans::ContentMutation::FieldAreaScopeAttributes, required: false)
          argument(:attachments, ::Decidim::Plans::ContentMutation::FieldAttachmentsAttributes, required: false)
          argument(:images, ::Decidim::Plans::ContentMutation::FieldImageAttachmentsAttributes, required: false)
          argument(:tags, ::Decidim::Plans::ContentMutation::FieldTagsAttributes, required: false)
        end
      end

      initializer "decidim_plans.proposals_integration" do
        next unless Decidim.const_defined?("Proposals")

        Decidim::Plans::ContentMutationAttributes.class_eval do
          argument(:proposals, ::Decidim::Plans::ContentMutation::FieldProposalsAttributes, required: false)
        end
        Decidim::Plans::ContentSubject.class_eval do
          possible_types(Decidim::Plans::SectionContent::LinkProposalsType)
        end
        Decidim::Plans::ResourceLinkSubject.class_eval do
          possible_types(Decidim::Proposals::ProposalType)
        end
        Decidim::Plans.section_types.register(:link_proposals) do |type|
          type.edit_cell = "decidim/plans/section_type_edit/link_proposals"
          type.content_form_class_name = "Decidim::Plans::ContentData::LinkProposalsForm"
          type.content_control_class_name = "Decidim::Plans::SectionControl::LinkProposals"
          type.api_type_class_name = "Decidim::Plans::SectionContent::LinkProposalsType"
        end
      end

      initializer "decidim_plans.budgets_integration" do
        next unless Decidim.const_defined?("Budgets")

        Decidim::Plans::ResourceLinkSubject.class_eval do
          possible_types(Decidim::Budgets::ProjectType)
        end
      end

      initializer "decidim_plans.accountability_integration" do
        next unless Decidim.const_defined?("Accountability")

        Decidim::Plans::ResourceLinkSubject.class_eval do
          possible_types(Decidim::Accountability::ResultType)
        end
      end

      initializer "decidim_plans.api_linked_resources", before: :finisher_hook do
        Decidim::Plans::PlanType.add_linked_resources_field
      end
    end
  end
end
