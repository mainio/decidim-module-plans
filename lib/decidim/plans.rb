# frozen_string_literal: true

require_relative "plans/version"
require_relative "plans/admin"
require_relative "plans/engine"
require_relative "plans/admin_engine"
require_relative "plans/paper_trail"
require_relative "plans/component"
require_relative "plans/locale_aware"
require_relative "plans/optionally_translatable_attributes"

module Decidim
  module Plans
    # Public: Stores an instance of Loggability
    def self.loggability
      @loggability ||= Loggability.new
    end

    # Public: Stores an instance of Tracer
    def self.tracer
      @tracer ||= Tracer.new
    end
  end
end
