# frozen_string_literal: true

module Decidim
  module Plans
    # This class acts as a registry for section types. Check the docs on the
    # `SectionTypeManifest` class to learn how they work.
    #
    # You will probably want to register your section types in an initializer in
    # the `engine.rb` file of your module.
    class SectionTypeRegistry < Decidim::Plans::ManifestRegistry
      private

      def manifest_class
        SectionTypeManifest
      end

      def registry_type
        :section_type
      end
    end
  end
end
