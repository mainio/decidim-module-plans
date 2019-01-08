# frozen_string_literal: true

require "decidim/core/test/factories"
require "decidim/participatory_processes/test/factories"

FactoryBot.define do
  factory :section, class: Decidim::Plans::Section do
    body { generate_localized_title }
    position { 0 }
    component
  end
end
