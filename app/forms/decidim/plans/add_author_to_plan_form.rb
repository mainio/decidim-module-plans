# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to add authors to a plan.
    class AddAuthorToPlanForm < Decidim::Form
      mimic :plan_authors

      # The field is named "recipient_id" because this is the default field name
      # added by the mentions script.
      attribute :recipient_id, Array[Integer]

      def plan
        @plan ||= Decidim::Plans::Plan.find(id) if id
      end

      def authors
        Decidim::User.where(id: recipient_id)
      end
    end
  end
end
