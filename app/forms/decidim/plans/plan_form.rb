# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when public users want to create a Plan.
    class PlanForm < Decidim::Form
      include OptionallyTranslatableAttributes
      mimic :plan

      alias component current_component

      optionally_translatable_attribute :title, String

      attribute :user_group_id, Integer
      attribute :category_id, Integer
      attribute :scope_id, Integer
      attribute :attachments, Array[Plans::AttachmentForm]
      attribute :contents, Array[ContentForm]
      attribute :proposal_ids, Array[Integer]

      validates :proposals, presence: true, if: ->(form) { form.current_component.settings.proposal_linking_enabled? }
      validates :category, presence: true, if: ->(form) { form.category_id.present? }
      validates :scope, presence: true, if: ->(form) { form.scope_id.present? }
      optionally_translatable_validate_presence :title

      validate :scope_belongs_to_participatory_space_scope

      delegate :categories, to: :current_component

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

      def map_model(model)
        self.contents = model.sections.map do |section|
          ContentForm.from_model(
            Content
              .where(plan: model, section: section)
              .first_or_initialize(plan: model, section: section)
          )
        end

        self.user_group_id = model.user_groups.first&.id
        return unless model.categorization

        self.category_id = model.categorization.decidim_category_id
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find user_group_id if user_group_id.present?
      end

      def proposals
        @proposals ||= Decidim
                       .find_resource_manifest(:proposals)
                       .try(:resource_scope, current_component)
                       &.where(id: proposal_ids)
                       &.order(title: :asc)
      end

      private

      def scope_belongs_to_participatory_space_scope
        errors.add(:scope_id, :invalid) if current_participatory_space.out_of_scope?(scope)
      end
    end
  end
end
