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
          get :search_proposals
          resources :plan_answers, only: [:edit, :update]
          resources :tags, except: [:show]
          resources :authors, only: [:index, :create, :destroy] do
            collection do
              patch :confirm
            end
          end
          member do
            get :taggings
            patch :update_taggings
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

      initializer "decidim_plans.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_plans_manifest.js
                                           decidim/plans/decidim_plans_manifest.js
                                           decidim/plans/proposal_picker.scss)
      end

      initializer "decidim_plans.mutation_extensions", after: "decidim-api.graphiql" do
        Decidim::Api::MutationType.define do
          MutationExtensions.define(self)
        end
      end

      config.to_prepare do
        Decidim::Admin::SettingsHelper.send(
          :include,
          Decidim::Plans::Admin::PlanComponentSettings
        )
      end
    end
  end
end
