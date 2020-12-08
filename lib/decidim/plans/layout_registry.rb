# frozen_string_literal: true

module Decidim
  module Plans
    # This class acts as a registry for plan layouts. Check the docs on the
    # `LayoutManifest` class to learn how they work.
    #
    # You will probably want to register your layouts in an initializer in the
    # `engine.rb` file of your module.
    class LayoutRegistry < Decidim::Plans::ManifestRegistry
      private

      def manifest_class
        LayoutManifest
      end

      def registry_type
        :view
      end
    end
  end
end
