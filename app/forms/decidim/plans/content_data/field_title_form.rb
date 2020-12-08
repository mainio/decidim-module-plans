# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the text field type.
      class FieldTitleForm < Decidim::Plans::ContentData::BaseForm
        include OptionallyTranslatableAttributes
        include Decidim::TranslationsHelper

        mimic :plan_title_field

        optionally_translatable_attribute :body, String

        # The translatable title is needed for the text fields in order to store
        # the multilingual values and provide the `body_xx` methods for the form
        # builder which builds the text fields or the editors.
        optionally_translatable_validate_presence :body, if: ->(form) { form.mandatory }

        def map_model(model)
          super

          self.body = model.plan.title
        end
      end
    end
  end
end
