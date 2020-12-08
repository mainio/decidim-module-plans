# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the checkbox field type.
      class FieldCheckboxForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_checkbox_field

        attribute :value, Boolean, default: false

        validates :value, presence: true, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          self.value = model.body["value"]
        end

        def body
          { value: value }
        end
      end
    end
  end
end
