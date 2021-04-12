# frozen_string_literal: true

require "decidim/favorites"

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
    autoload :ManifestRegistry, "decidim/plans/manifest_registry"
    autoload :SectionTypeManifest, "decidim/plans/section_type_manifest"
    autoload :SectionTypeRegistry, "decidim/plans/section_type_registry"
    autoload :LayoutManifest, "decidim/plans/layout_manifest"
    autoload :LayoutRegistry, "decidim/plans/layout_registry"

    include ActiveSupport::Configurable

    # Defines whether the help sections are shown as help texts below the fields
    # (false) or as tooltips (true).
    config_accessor :section_edit_tooltips do
      false
    end

    config_accessor :attachment_image_versions do
      {
        big: { resize_to_limit: [nil, 1000] },
        main: { resize_to_fill: [1480, 740] },
        thumbnail: { resize_to_fill: [860, 340] }
      }
    end

    # Defines a default card image for the plan cards
    config_accessor :default_card_image

    # Public: Stores an instance of Loggability
    def self.loggability
      @loggability ||= Loggability.new
    end

    # Public: Stores an instance of Tracer
    def self.tracer
      @tracer ||= Tracer.new
    end

    # Public: Stores the registry of section types
    def self.section_types
      @section_types ||= SectionTypeRegistry.new
    end

    # Public: Stores the registry of layouts
    def self.layouts
      @layouts ||= LayoutRegistry.new
    end
  end

  module ContentParsers
    autoload :PlanParser, "decidim/content_parsers/plan_parser"
  end

  module ContentRenderers
    autoload :PlanRenderer, "decidim/content_renderers/plan_renderer"
  end
end
