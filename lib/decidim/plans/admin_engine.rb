# frozen_string_literal: true

module Decidim
  module Plans
    # This is the engine that runs on the public interface of `decidim-plans`.
    class AdminEngine < ::Rails::Engine
      isolate_namespace Decidim::Plans::Admin

      paths["db/migrate"] = nil
      paths["lib/tasks"] = nil

      routes do
        resources :plans, only: [:index, :new, :create, :edit, :update] do
          collection do
            get :search_proposals
            get :search_plans
          end
          resources :plan_answers, only: [:edit, :update]
          resources :authors, only: [:index, :create, :destroy] do
            collection do
              patch :confirm
            end
          end
          resources :organization_authors, controller: :authors, path: "authors/organization", only: [] do
            member do
              delete "/", action: :destroy_organization
            end
          end
          resource :taggings, only: [:show, :update]
          member do
            post :close
            post :reopen
          end
          collection do
            resource :budgets_export, only: [:new, :create]
          end
        end
        resources :sections, only: [:index, :new, :create, :edit, :update]
        resources :scopes, only: [:index]

        root to: "plans#index"
      end

      initializer "decidim_plans_admin.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.include(Decidim::Plans::MutationExtensions)
      end

      initializer "decidim_plans_admin.overrides", after: "decidim.action_controller" do |app|
        app.config.to_prepare do
          Decidim::Admin::SettingsHelper.include Decidim::Plans::Admin::PlanComponentSettings
        end
      end

      initializer "decidim_core.register_icons", after: "decidim_core.add_social_share_services" do
        Decidim.icons.register(name: "price-tag-line", icon: "price-tag-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "arrow-go-back-line", icon: "arrow-go-back-line", category: "system", description: "", engine: :core)
        Decidim.icons.register(name: "chat-4-line", icon: "chat-4-line", category: "system", description: "", engine: :core)
      end
    end
  end
end
