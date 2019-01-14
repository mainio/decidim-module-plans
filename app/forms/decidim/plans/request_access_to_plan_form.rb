# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when public users want to request acces to a Plan.
    class RequestAccessToPlanForm < Decidim::Form
      mimic :plan

      attribute :id, String
      attribute :state, String

      validates :id, presence: true
      validates :state, presence: true, inclusion: { in: %w(open) }

      def plan
        @plan ||= Decidim::Plans::Plan.find id
      end
    end
  end
end
