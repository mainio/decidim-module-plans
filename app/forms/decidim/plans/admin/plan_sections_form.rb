# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class PlanSectionsForm < Decidim::Form
        include Decidim::ApplicationHelper

        attribute :sections, Array[SectionForm]
      end
    end
  end
end
