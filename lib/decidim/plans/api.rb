# frozen_string_literal: true

module Decidim
  module Plans
    autoload :CoauthorableInterface, "decidim/plans/api/coauthorable_interface"
    autoload :TimestampsInterface, "decidim/plans/api/timestamps_interface"
    autoload :TraceableInterface, "decidim/plans/api/traceable_interface"
  end
end
