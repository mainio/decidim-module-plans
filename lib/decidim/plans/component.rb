# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:plans) do |component|
  component.engine = Decidim::Plans::Engine
  component.admin_engine = Decidim::Plans::AdminEngine
  component.icon = "decidim/plans/icon.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are plans" if Decidim::Plans::Plan.where(component: instance).any?
  end

  component.data_portable_entities = ["Decidim::Plans::Plan"]

  component.actions = %w(create withdraw)

  component.permissions_class_name = "Decidim::Plans::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :plan_answering_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :attachments_allowed, type: :boolean, default: false
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :plan_answering_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:plan) do |resource|
    resource.model_class_name = "Decidim::Plans::Plan"
    resource.card = "decidim/plans/plan"
  end

  component.register_stat :plans_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Plans::FilteredPlans.for(components, start_at, end_at).published.except_withdrawn.not_hidden.count
  end

  component.register_stat :plans_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Plans::FilteredPlans.for(components, start_at, end_at).accepted.count
  end

  component.seeds do |participatory_space|
    admin_user = Decidim::User.find_by(
      organization: participatory_space.organization,
      email: "admin@example.org"
    )

    step_settings = if participatory_space.allows_steps?
                      { participatory_space.active_step.id => { creation_enabled: true } }
                    else
                      {}
                    end

    params = {
      name: Decidim::Components::Namer.new(participatory_space.organization.available_locales, :plans).i18n_name,
      manifest_name: :plans,
      published_at: Time.current,
      participatory_space: participatory_space,
      settings: {},
      step_settings: step_settings
    }

    component = Decidim.traceability.perform_action!(
      "publish",
      Decidim::Component,
      admin_user,
      visibility: "all"
    ) do
      Decidim::Component.create!(params)
    end

    if participatory_space.scope
      scopes = participatory_space.scope.descendants
      global = participatory_space.scope
    else
      scopes = participatory_space.organization.scopes
      global = nil
    end

    5.times do |n|
      Decidim::Plans::Section.create!(
        component: component,
        body: Decidim::Faker::Localized.paragraph,
        position: n
      )
    end

    5.times do |n|
      state, answer = if n > 3
                        ["accepted", Decidim::Faker::Localized.sentence(10)]
                      elsif n > 2
                        ["rejected", nil]
                      elsif n > 1
                        ["evaluating", nil]
                      else
                        [nil, nil]
                      end

      params = {
        component: component,
        category: participatory_space.categories.sample,
        scope: Faker::Boolean.boolean(0.5) ? global : scopes.sample,
        title: Decidim::Faker::Localized.sentence(2),
        state: state,
        answer: answer,
        answered_at: Time.current,
        published_at: Time.current
      }

      plan = Decidim.traceability.perform_action!(
        "publish",
        Decidim::Plans::Plan,
        admin_user,
        visibility: "all"
      ) do
        plan = Decidim::Plans::Plan.new(params)
        plan.add_coauthor(participatory_space.organization)
        plan.save!
        plan
      end

      if n.positive?
        Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
          user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil
          plan.add_coauthor(author, user_group: user_group)
        end
      end

      Decidim::Comments::Seed.comments_for(plan)
    end
  end
end
