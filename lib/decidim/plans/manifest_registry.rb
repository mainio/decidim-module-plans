# frozen_string_literal: true

module Decidim
  module Plans
    # This class acts as a base registry for storing the manifests for different
    # purposes. Check the docs in one of the extending classes to learn more.
    class ManifestRegistry
      # Public: Registers a new manifest in the registry.
      #
      # name - a symbol representing the name of the manifest
      # &block - The manifest definition.
      #
      # Returns nothing. Raises an error if there's already a manifest in this
      # registry registered with that name.
      def register(name)
        name = name.to_s

        if find(name).present?
          raise(
            ManifestAlreadyRegistered,
            "There's a #{registry_name} already registered with the name `:#{name}`, must be unique"
          )
        end

        section_type = manifest_class.new(name: name)

        yield(section_type) if block_given?

        section_type.validate!
        all << section_type
      end

      def find(name)
        name = name.to_s
        all.find { |manifest| manifest.name.to_s == name }
      end

      def all
        @all ||= Set.new
      end

      private

      def manifest_class
        raise(
          ManifestClassNotDefined,
          "Manifest class is not defined"
        )
      end

      def registry_type
        raise(
          RegistryTypeNotDefined,
          "Manifest registry type is not defined"
        )
      end

      def registry_name
        registry_type.humanize(capitalize: false)
      end

      class ManifestAlreadyRegistered < StandardError; end
      class ManifestClassNotDefined < StandardError; end
      class RegistryTypeNotDefined < StandardError; end
    end
  end
end
