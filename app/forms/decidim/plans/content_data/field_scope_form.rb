# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the scope field type.
      class FieldScopeForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_scope_field

        attribute :scope_id, Integer

        validates :scope_id, presence: true, if: ->(form) { form.mandatory }
        validate :scope_belongs_to_organization

        delegate :organization, to: :current_component

        def map_model(model)
          super

          self.scope_id = model.body["scope_id"]
        end

        def body
          { scope_id: scope_id }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          self.scope_id = data["scope_id"] || data[:scope_id]
        end

        private

        # Finds the Scope from the given decidim_scope_id, uses participatory space scope if missing.
        #
        # Returns a Decidim::Scope
        def scope
          @scope ||= @scope_id ? current_participatory_space.scopes.find_by(id: @scope_id) : current_participatory_space.scope
        end

        def scope_belongs_to_organization
          return unless scope

          errors.add(:scope_id, :invalid) if scope.organization != organization
        end
      end
    end
  end
end
