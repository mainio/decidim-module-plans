# frozen_string_literal: true

module Decidim
  module Plans
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Plans

      routes do
        resources :plans, except: [:destroy] do
          get :search_proposals
          resource :plan_widget, only: :show, path: "embed"
          resources :versions, only: [:show, :index]
          member do
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
                                           decidim/plans/decidim_plans_manifest.js)
      end

      initializer "decidim_plans.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/views") # for partials
      end
    end
  end
end
