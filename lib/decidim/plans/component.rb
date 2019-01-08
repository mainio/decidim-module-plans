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
  end
end
