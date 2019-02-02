# frozen_string_literal: true

require "paper_trail-association_tracking"
require_relative "paper_trail/record_trail"

module PaperTrail
  class RecordTrail
    prepend ::Decidim::Plans::PaperTrail::RecordTrail
  end
end
