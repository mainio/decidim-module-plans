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
            post :request_access, controller: "plan_collaborator_requests"
            post :request_accept, controller: "plan_collaborator_requests"
            post :request_reject, controller: "plan_collaborator_requests"
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
    end
  end
end
