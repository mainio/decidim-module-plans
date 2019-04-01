# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class TaggingsForm < Decidim::Form
        include Decidim::ApplicationHelper

        mimic :tagging

        attribute :tags, Array[Integer]

        def map_model(plan)
          self.tags = plan.tags.map { |tag| tag.id }
        end
      end
    end
  end
end
