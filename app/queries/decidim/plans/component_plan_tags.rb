# frozen_string_literal: true

module Decidim
  module Plans
    # This query class filters all assemblies given an organization.
    class ComponentPlanTags < Decidim::Tags::ComponentRecordTags
      taggable Decidim::Plans::Plan
    end
  end
end
