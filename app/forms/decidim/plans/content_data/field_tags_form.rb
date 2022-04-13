# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for the scope field type.
      class FieldTagsForm < Decidim::Plans::ContentData::BaseForm
        mimic :plan_scope_field

        attribute :taggings, Decidim::Tags::TaggingsForm

        delegate :organization, to: :current_component

        def map_model(model)
          super

          tags = begin
            if model.body["tag_ids"].is_a?(Array)
              model.body["tag_ids"]
            else
              []
            end
          end

          self.taggings = Decidim::Tags::TaggingsForm.from_params(tags: tags)
        end

        def body
          return { tag_ids: [] } unless taggings

          { tag_ids: taggings.tags }
        end

        def body=(data)
          return unless data.is_a?(Hash)

          tags = begin
            if data["tag_ids"].is_a?(Array) || data[:tag_ids].is_a?(Array)
              data["tag_ids"] || data[:tag_ids]
            else
              []
            end
          end

          self.taggings = Decidim::Tags::TaggingsForm.from_params(tags: tags)
        end
      end
    end
  end
end
