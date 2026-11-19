# frozen_string_literal: true

require "decidim/components/namer"

Decidim.register_component(:plans) do |component|
  component.engine = Decidim::Plans::Engine
  component.admin_engine = Decidim::Plans::AdminEngine
  component.icon = "media/images/decidim_plans.svg"

  component.on(:before_destroy) do |instance|
    raise "Can't destroy this component when there are plans" if Decidim::Plans::Plan.where(component: instance).any?
  end

  component.data_portable_entities = ["Decidim::Plans::Plan"]

  component.actions = %w(create withdraw close reopen)

  component.query_type = "Decidim::Plans::PlansType"

  component.permissions_class_name = "Decidim::Plans::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :plan_answering_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :form_preview_allowed, type: :boolean, default: false
    settings.attribute :closing_allowed, type: :boolean, default: false
    settings.attribute :multilingual_answers, type: :boolean
    settings.attribute :layout, type: :plan_layout
    settings.attribute :default_state, type: :plan_state
    settings.attribute :default_answer, type: :text, translated: true, editor: true
    settings.attribute :plan_listing_intro, type: :text, translated: true, editor: true
    settings.attribute :new_plan_help_text, type: :text, translated: true, editor: true
    settings.attribute :materials_text, type: :text, translated: true, editor: true
    settings.attribute :taxonomy_filters, type: :taxonomy_filters
  end

  component.settings(:step) do |settings|
    settings.attribute :comments_blocked, type: :boolean, default: false
    settings.attribute :creation_enabled, type: :boolean
    settings.attribute :plan_answering_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
  end

  component.register_resource(:plan) do |resource|
    resource.model_class_name = "Decidim::Plans::Plan"
    resource.template = "decidim/plans/plans/linked_plans"
    resource.card = "decidim/plans/plan"
    resource.searchable = true
  end

  component.register_stat :plans_count, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Plans::FilteredPlans.for(components, start_at, end_at).not_hidden.count
  end

  component.register_stat :plans_accepted, primary: true, priority: Decidim::StatsRegistry::HIGH_PRIORITY do |components, start_at, end_at|
    Decidim::Plans::FilteredPlans.for(components, start_at, end_at).accepted.count
  end

  component.register_stat :comments_count, tag: :comments do |components, start_at, end_at|
    plans = Decidim::Plans::FilteredPlans.for(components, start_at, end_at).published.not_hidden
    Decidim::Comments::Comment.where(root_commentable: plans).count
  end

  component.exports :plans do |exports|
    exports.collection do |component_instance|
      Decidim::Plans::Plan
        .published
        .where(component: component_instance)
        .includes(:category, :taxonomies, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Plans::PlanSerializer
  end

  component.seeds do |participatory_space|
    Decidim::Plans::Seeds.new(participatory_space:).call
  end
end
