# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldTagsCell < Decidim::Plans::SectionDisplayCell
        def show
          return unless tags.any?

          render
        end

        private

        # The tags object is necessary not to display ALL the tags related to
        # the plan but only the ones related to this particular section.
        # Otherwise the cell provided by the Tags module would display all tags
        # related to the plan.
        def tags_object
          @tags_object ||= OpenStruct.new(tags:)
        end

        def tags
          return [] unless model.body
          return [] unless model.body["tag_ids"].is_a?(Array)

          @tags ||= Decidim::Tags::Tag.where(id: model.body["tag_ids"])
        end
      end
    end
  end
end
