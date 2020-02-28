# frozen_string_literal: true

module Decidim
  module Plans
    # This module's job is to extend the API with custom fields related to
    # decidim-plans.
    module MutationExtensions
      # Public: Extends a type with `decidim-plans`'s fields.
      #
      # type - A GraphQL::BaseType to extend.
      #
      # Returns nothing.
      def self.define(type)
        type.field :plan, Decidim::Plans::PlanMutationType do
          description "A plan"

          argument :id, !types.ID, description: "The plan's id"

          resolve lambda { |_obj, args, _ctx|
            Plan.find(args[:id])
          }
        end
      end
    end
  end
end
