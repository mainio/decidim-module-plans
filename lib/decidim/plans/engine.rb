# frozen_string_literal: true

module Decidim
  module Plans
    class Engine < ::Rails::Engine
      isolate_namespace Decidim::Plans

      routes do
        resources :plans, except: [:destroy] do
          resource :plan_endorsement, only: [:create, :destroy] do
            get :identities, on: :collection
          end
          resource :plan_vote, only: [:create, :destroy]
          resource :plan_widget, only: :show, path: "embed"
          resources :versions, only: [:show, :index]
        end

        root to: "plans#index"
      end

      initializer "decidim_plans.assets" do |app|
        app.config.assets.precompile += %w(decidim_plans_manifest.js
                                           decidim_plans_manifest.css
                                           decidim/plans/identity_selector_dialog.js)
      end

      initializer "decidim_plans.view_hooks" do
        Decidim.view_hooks.register(:participatory_space_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY) do |view_context|
          view_context.cell("decidim/plans/highlighted_plans", view_context.current_participatory_space)
        end

        if defined? Decidim::ParticipatoryProcesses
          Decidim::ParticipatoryProcesses.view_hooks.register(
            :process_group_highlighted_elements, priority: Decidim::ViewHooks::MEDIUM_PRIORITY
          ) do |view_context|
            published_components = Decidim::Component.where(
              participatory_space: view_context.participatory_processes
            ).published
            plans = Decidim::Plans::Plan.published.not_hidden.except_withdrawn
                                        .where(component: published_components)
                                        .order_randomly(rand * 2 - 1)
                                        .limit(Decidim::Plans.config.process_group_highlighted_plans_limit)

            next unless plans.any?

            view_context.extend Decidim::ResourceReferenceHelper
            view_context.extend Decidim::Plans::ApplicationHelper
            view_context.render(
              partial: "decidim/participatory_processes/participatory_process_groups/highlighted_plans",
              locals: {
                plans: plans
              }
            )
          end
        end
      end

      initializer "decidim_plans.add_cells_view_paths" do
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/cells")
        Cell::ViewModel.view_paths << File.expand_path("#{Decidim::Plans::Engine.root}/app/views") # for partials
      end
    end
  end
end
