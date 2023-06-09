# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :section, class: "Decidim::Plans::Section" do
    section_type { Decidim::Plans::Section.types.first }
    body { generate_localized_title }
    position { 0 }
    mandatory { false }
    settings { { answer_length: 0 } }
    component
  end

  factory :content, class: "Decidim::Plans::Content" do
    body { generate_localized_title }
    plan
    section { create(:section) }
    user { create(:user, organization: plan.organization) }
  end

  factory :plan_component, parent: :component do
    name { Decidim::Components::Namer.new(participatory_space.organization.available_locales, :plans).i18n_name }
    manifest_name { :plans }
    participatory_space { create(:participatory_process, :with_steps, organization: organization) }

    trait :with_creation_enabled do
      step_settings do
        {
          participatory_space.active_step.id => { creation_enabled: true }
        }
      end
    end

    trait :with_attachments_allowed do
      settings do
        {
          attachments_allowed: true
        }
      end
    end

    trait :with_closing_allowed do
      settings do
        {
          closing_allowed: true
        }
      end
    end

    trait :with_multilingual_answers do
      settings do
        {
          multilingual_answers: true
        }
      end
    end

    trait :with_proposal_linking_disabled do
      settings do
        {
          proposal_linking_enabled: false
        }
      end
    end

    trait :with_default_state do
      transient do
        default_state { nil }
        default_answer { nil }
      end

      settings do
        {
          default_state: default_state,
          default_answer: default_answer
        }
      end
    end
  end

  factory :plan, class: "Decidim::Plans::Plan" do
    transient do
      users { nil }
      plan_proposals { nil }
      # user_groups correspondence to users is by sorting order
      user_groups { [] }
      tags { [] }
    end

    title { generate_localized_title }
    component { create(:plan_component) }
    published_at { Time.current }

    after(:build) do |plan, evaluator|
      if plan.component
        users = evaluator.users || [create(:user, organization: plan.component.participatory_space.organization)]
        users.each_with_index do |user, idx|
          user_group = evaluator.user_groups[idx]
          plan.coauthorships.build(author: user, user_group: user_group)
        end

        if FactoryBot.factories.registered?(:proposal_component)
          proposal_component = create(:proposal_component, participatory_space: plan.component.participatory_space)
          proposals = evaluator.plan_proposals || [create(:proposal, component: proposal_component)]
          plan.link_resources(proposals, "included_proposals")
        end
      end
      plan.update!(tags: evaluator.tags) if evaluator.tags && evaluator.tags.count.positive?
    end

    trait :published do
      published_at { Time.current }
    end

    trait :unpublished do
      published_at { nil }
    end

    trait :official do
      after :build do |plan|
        plan.coauthorships.clear
        plan.coauthorships.build(author: plan.organization)
      end
    end

    trait :evaluating do
      state { "evaluating" }
      answered_at { Time.current }
    end

    trait :accepted do
      state { "accepted" }
      answered_at { Time.current }
    end

    trait :rejected do
      state { "rejected" }
      answered_at { Time.current }
    end

    trait :withdrawn do
      state { "withdrawn" }
    end

    trait :with_answer do
      state { "accepted" }
      answer { generate_localized_title }
      answered_at { Time.current }
    end

    trait :open do
      state { "open" }
    end

    trait :draft do
      published_at { nil }
    end
  end

  factory :plan_collaborator_request, class: "Decidim::Plans::PlanCollaboratorRequest" do
    plan
    user
  end

  factory :tag, class: "Decidim::Plans::Tag" do
    name { generate_localized_title }
    organization { create(:organization) }
  end
end
