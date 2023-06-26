# frozen_string_literal: true

require "active_support/concern"

module Decidim
  module Plans
    # Common logic to ordering resources
    module Orderable
      extend ActiveSupport::Concern

      included do
        helper_method :order, :available_orders, :random_seed

        private

        # Gets how the plans should be ordered based on the choice made by the user.
        def order
          @order ||= detect_order(params[:order]) || default_order
        end

        # Available orders based on enabled settings
        def available_orders
          @available_orders ||= begin
            available_orders = %w(recent random)
            available_orders
          end
        end

        def default_order
          "recent"
        end

        # Returns: A random float number between -1 and 1 to be used as a random seed at the database.
        def random_seed
          @random_seed ||= (params[:random_seed] ? params[:random_seed].to_f : (rand * 2 - 1))
        end

        def detect_order(candidate)
          available_orders.detect { |order| order == candidate }
        end

        def reorder(plans)
          case order
          when "random"
            plans.order_randomly(random_seed)
          when "recent"
            plans.order(created_at: :desc)
          end
        end
      end
    end
  end
end
