# frozen-string_literal: true

module Decidim
  module Plans
    class RejectedPlanEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
