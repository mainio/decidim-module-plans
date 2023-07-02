# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :section, class: "Decidim::Plans::Section" do
    section_type { "field_text" }
    body { generate_localized_title }
    position { 0 }
    mandatory { false }
    settings { { answer_length: 0 } }
    component
    searchable { true }
    visible_form { true }
    visible_view { true }
    visible_api { true }

    trait :field_title do
      section_type { "field_title" }
    end

    trait :field_text do
      section_type { "field_text" }
    end

    trait :field_text_multiline do
      section_type { "field_text_multiline" }
    end

    trait :field_number do
      section_type { "field_number" }
    end

    trait :field_currency do
      section_type { "field_currency" }
    end

    trait :field_checkbox do
      section_type { "field_checkbox" }
    end

    trait :field_scope do
      transient do
        scope_parent { create(:scope, organization: component.organization) }
      end

      section_type { "field_scope" }
      settings { { scope_parent: scope_parent&.id } }
    end

    trait :field_area_scope do
      transient do
        area_scope_parent { create(:scope, organization: component.organization) }
      end

      section_type { "field_area_scope" }
      settings { { area_scope_parent: area_scope_parent&.id } }
    end

    trait :field_category do
      section_type { "field_category" }
    end

    trait :field_tags do
      section_type { "field_tags" }
    end

    trait :field_map_point do
      section_type { "field_map_point" }
    end

    trait :field_attachments do
      section_type { "field_attachments" }
    end

    trait :field_image_attachments do
      section_type { "field_image_attachments" }
    end

    trait :content do
      section_type { "content" }
    end

    trait :link_proposals do
      section_type { "link_proposals" }
    end
  end

  factory :content, class: "Decidim::Plans::Content" do
    body { generate_localized_title }
    plan
    section { create(:section, :field_text, component: plan.component) }
    user { create(:user, :confirmed, organization: plan.organization) }

    trait :field_title do
      body { generate_localized_title }
      section { create(:section, :field_title, component: plan.component) }
    end

    trait :field_text do
      body { generate_localized_title }
      section { create(:section, :field_text, component: plan.component) }
    end

    trait :field_text_multiline do
      body { generate_localized_title }
      section { create(:section, :field_text_multiline, component: plan.component) }
    end

    trait :field_number do
      body { { value: Faker::Number.number } }
      section { create(:section, :field_number, component: plan.component) }
    end

    trait :field_currency do
      body { { value: Faker::Number.number } }
      section { create(:section, :field_currency, component: plan.component) }
    end

    trait :field_checkbox do
      body { { value: Faker::Boolean.boolean } }
      section { create(:section, :field_checkbox, component: plan.component) }
    end

    trait :field_scope do
      transient do
        scope { create(:scope, organization: plan.organization) }
      end

      body { { scope_id: scope&.id } }
      section { create(:section, :field_scope, component: plan.component) }
    end

    trait :field_area_scope do
      transient do
        scope { create(:scope, organization: plan.organization) }
      end

      body { { scope_id: scope&.id } }
      section { create(:section, :field_area_scope, component: plan.component) }
    end

    trait :field_category do
      transient do
        category { create(:category, participatory_space: plan.participatory_space) }
      end

      body { { category_id: category&.id } }
      section { create(:section, :field_category, component: plan.component) }
    end

    trait :field_tags do
      transient do
        tags { create_list(:tag, 2, organization: plan.organization) }
      end

      body { { tag_ids: tags.map(&:id) } }
      section { create(:section, :field_tags, component: plan.component) }
    end

    trait :field_map_point do
      transient do
        address { "#{Faker::Address.street_name}, #{Faker::Address.city}" }
        latitude { Faker::Address.latitude }
        longitude { Faker::Address.longitude }
      end

      body { { address: address, latitude: latitude, longitude: longitude } }
      section { create(:section, :field_map_point, component: plan.component) }
    end

    trait :field_attachments do
      transient do
        documents { create_list(:attachment, 3, :with_pdf, attached_to: plan) }
        images { create_list(:attachment, 3, :with_image, attached_to: plan) }
      end

      body { { "attachment_ids" => (documents.map(&:id) + images.map(&:id)) } }
      section { create(:section, :field_attachments, component: plan.component) }
    end

    trait :field_image_attachments do
      transient do
        images { create_list(:attachment, 3, :with_image, attached_to: plan) }
      end

      body { { "attachment_ids" => images.map(&:id) } }
      section { create(:section, :field_image_attachments, component: plan.component) }
    end

    trait :link_proposals do
      transient do
        proposals { create_list(:proposal, 2, component: create(:proposal_component, participatory_space: plan.participatory_space)) }
      end

      body { { "proposal_ids" => proposals.map(&:id) } }
      section { create(:section, :link_proposals, component: plan.component) }
    end
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
        users = evaluator.users || [create(:user, :confirmed, organization: plan.component.participatory_space.organization)]
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
end
