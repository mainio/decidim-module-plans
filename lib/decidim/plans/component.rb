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

  component.actions = %w(create withdraw close reopen)

  component.query_type = "Decidim::Plans::PlansType"

  component.permissions_class_name = "Decidim::Plans::Permissions"

  component.settings(:global) do |settings|
    settings.attribute :plan_answering_enabled, type: :boolean, default: true
    settings.attribute :comments_enabled, type: :boolean, default: true
    settings.attribute :announcement, type: :text, translated: true, editor: true
    settings.attribute :closing_allowed, type: :boolean, default: false
    settings.attribute :multilingual_answers, type: :boolean
    settings.attribute :layout, type: :plan_layout
    settings.attribute :default_state, type: :plan_state
    settings.attribute :default_answer, type: :text, translated: true, editor: true
    settings.attribute :plan_listing_intro, type: :text, translated: true, editor: true
    settings.attribute :new_plan_help_text, type: :text, translated: true, editor: true
    settings.attribute :materials_text, type: :text, translated: true, editor: true
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
        .includes(:category, component: { participatory_space: :organization })
    end

    exports.include_in_open_data = true

    exports.serializer Decidim::Plans::PlanSerializer
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
      settings: {
        multilingual_answers: false,
        scope_id: participatory_space.scope&.id
      },
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

    Decidim::Plans::Section.create!(
      component: component,
      body: Decidim::Faker::Localized.paragraph,
      help: Decidim::Faker::Localized.paragraph,
      mandatory: true,
      position: 0,
      handle: "title",
      section_type: "field_title"
    )

    5.times do |n|
      Decidim::Plans::Section.create!(
        component: component,
        body: Decidim::Faker::Localized.paragraph,
        help: Decidim::Faker::Localized.paragraph,
        mandatory: false,
        position: n + 1,
        handle: "section_#{n}",
        section_type: "field_text_multiline"
      )
    end

    proposal_component = participatory_space.components.find_by(manifest_name: "proposals")
    proposals = begin
      if proposal_component
        Decidim::Proposals::Proposal.where(component: proposal_component).to_a
      else
        []
      end
    end

    5.times do |n|
      state, answer = if n > 3
                        ["accepted", Decidim::Faker::Localized.sentence(word_count: 10)]
                      elsif n > 2
                        ["rejected", Decidim::Faker::Localized.sentence(word_count: 10)]
                      elsif n > 1
                        ["evaluating", nil]
                      else
                        [nil, nil]
                      end

      # Check whether the plan is answered and set it closed by random if not.
      is_answered = !state.nil?
      is_closed = is_answered || rand < 0.5

      # Force the state to be "evaluating" for closed but unanswered plans
      state = "evaluating" if is_closed && !is_answered

      params = {
        component: component,
        category: participatory_space.categories.sample,
        scope: Faker::Boolean.boolean(true_ratio: 0.5) ? global : scopes.sample,
        title: Decidim::Faker::Localized.sentence(word_count: 2),
        state: state,
        answer: answer,
        closed_at: is_closed ? Time.current : nil,
        answered_at: is_answered ? Time.current : nil,
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

        unless proposals.empty?
          linked_proposals = begin
            if proposals.length > 2
              proposals.slice!(0, 2)
            else
              proposals
            end
          end
          plan.link_resources(linked_proposals, "included_proposals")
        end

        plan
      end

      if n.positive?
        Decidim::User.where(decidim_organization_id: participatory_space.decidim_organization_id).all.sample(n).each do |author|
          user_group = [true, false].sample ? Decidim::UserGroups::ManageableUserGroups.for(author).verified.sample : nil
          plan.add_coauthor(author, user_group: user_group)
        end
      end

      Decidim::Plans::Section.where(component: component).each do |section|
        plan.contents.create!(
          body: Decidim::Faker::Localized.paragraph,
          section: section,
          user: admin_user
        )
      end

      Decidim::Comments::Seed.comments_for(plan)
    end
  end
end
