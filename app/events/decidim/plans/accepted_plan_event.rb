# frozen_string_literal: true

module Decidim
  module Plans
    class AcceptedPlanEvent < Decidim::Events::SimpleEvent
      include Decidim::Events::AuthorEvent
    end
  end
end
