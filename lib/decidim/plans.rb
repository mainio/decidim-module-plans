# frozen_string_literal: true

require_relative "plans/version"
require_relative "plans/admin"
require_relative "plans/engine"
require_relative "plans/admin_engine"
require_relative "plans/paper_trail"
require_relative "plans/component_settings_extensions"
require_relative "plans/component"
require_relative "plans/api"

module Decidim
  module Plans
    autoload :LocaleAware, "decidim/plans/locale_aware"
    autoload :OptionallyTranslatableAttributes, "decidim/plans/optionally_translatable_attributes"
    autoload :PlanSerializer, "decidim/plans/plan_serializer"
    autoload :MutationExtensions, "decidim/plans/mutation_extensions"

    # Public: Stores an instance of Loggability
    def self.loggability
      @loggability ||= Loggability.new
    end

    # Public: Stores an instance of Tracer
    def self.tracer
      @tracer ||= Tracer.new
    end

    # Public: Stores the possible content types and adds the possibility to add
    # new ones.
    def self.api_content_types
      [
        Decidim::Plans::SectionContent::ContentType,
        Decidim::Plans::SectionContent::FieldAttachmentsType,
        Decidim::Plans::SectionContent::FieldAreaScopeType,
        Decidim::Plans::SectionContent::FieldCategoryType,
        Decidim::Plans::SectionContent::FieldCheckboxType,
        Decidim::Plans::SectionContent::FieldImageAttachmentsType,
        Decidim::Plans::SectionContent::FieldMapPointType,
        Decidim::Plans::SectionContent::FieldScopeType,
        Decidim::Plans::SectionContent::FieldTextType,
        Decidim::Plans::SectionContent::FieldNumberType
      ]
    end

    # Public: Stores the possible resource link types and adds the possibility
    # to add new ones.
    def self.api_resource_link_types
      @api_resource_link_types ||= [Decidim::Proposals::ProposalType]
    end
  end

  module ContentParsers
    autoload :PlanParser, "decidim/content_parsers/plan_parser"
  end

  module ContentRenderers
    autoload :PlanRenderer, "decidim/content_renderers/plan_renderer"
  end
end
