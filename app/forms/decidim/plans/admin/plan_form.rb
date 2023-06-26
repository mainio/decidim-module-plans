# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class PlanForm < Decidim::Form
        include OptionallyTranslatableAttributes
        include Decidim::ApplicationHelper
        mimic :plan

        attribute :category_id, Integer
        attribute :scope_id, Integer
        attribute :contents, Array

        # When a plan is updated, the user can optionally pass a version comment
        # in the version_comment attribute.
        translatable_attribute :version_comment, String

        validates :category, presence: true, if: ->(form) { form.category_id.present? }
        validates :scope, presence: true, if: ->(form) { form.scope_id.present? }

        validate :scope_belongs_to_participatory_space_scope

        delegate :categories, to: :current_component

        def self.from_params(params, additional_params = {})
          form = super
          form.contents = form.contents.map do |section_params|
            ContentForm.from_params(section_params, additional_params)
          end

          form
        end

        def map_model(model)
          self.contents = model.sections.map do |section|
            ContentForm.from_model(
              Content
                .where(plan: model, section: section)
                .first_or_initialize(plan: model, section: section, body: {})
            )
          end

          self.scope_id = model.decidim_scope_id if model.scope
          self.category_id = model.categorization.decidim_category_id if model.categorization
        end

        alias component current_component

        # Finds the Category from the category_id.
        #
        # Returns a Decidim::Category
        def category
          @category ||= categories.find_by(id: category_id)
        end

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @scope_id ? current_participatory_space.scopes.find_by(id: @scope_id) : current_participatory_space.scope
        end

        # Scope identifier
        #
        # Returns the scope identifier related to the plan
        def scope_id
          @scope_id || scope&.id
        end

        def author
          current_organization
        end

        private

        def scope_belongs_to_participatory_space_scope
          errors.add(:scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
        end
      end
    end
  end
end
