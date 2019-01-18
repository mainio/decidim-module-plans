# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :section, class: Decidim::Plans::Section do
    body { generate_localized_title }
    position { 0 }
    component
  end

  factory :content, class: Decidim::Plans::Content do
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
  end

  factory :plan, class: "Decidim::Plans::Plan" do
    transient do
      users { nil }
      # user_groups correspondence to users is by sorting order
      user_groups { [] }
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
      end
    end

    trait :published do
      published_at { Time.current }
    end

    trait :unpublished do
      published_at { nil }
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
end
