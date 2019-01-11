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
          resources :plans_answers, only: [:edit, :update]
        end
        resources :sections, only: [:index, :new, :create, :edit, :update]

        root to: "plans#index"
      end

      initializer "decidim_plans.admin_assets" do |app|
        app.config.assets.precompile += %w(admin/decidim_plans_manifest.js)
      end
    end
  end
end
