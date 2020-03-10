# frozen_string_literal: true

module Decidim
  module Plans
    class DiffCell < Decidim::DiffCell
      delegate :component_settings, :current_locale, to: :controller

      # The changesets for each attribute.
      #
      # Each changeset has the following information:
      # type, label, old_value, new_value.
      #
      # Returns an Array of Hashes.
      def diff_data
        diff_renderers.map do |renderer|
          renderer.diff.values
        end.flatten
      end

      # DiffRenderer class for the current_version's item.
      def diff_renderer_class
        diff_renderer_class_for(current_version)
      end

      def diff_renderer_class_for(version)
        return Decidim::Plans::DiffRenderer::Base if version.item.nil?

        item_klass = version.item.class.name
        lastpart = item_klass.split("::").last
        renderer_klass = "Decidim::Plans::DiffRenderer::#{lastpart}"

        renderer_klass.constantize
      rescue NameError
        Decidim::Plans::DiffRenderer::Base
      end

      # Caches a DiffRenderer instance for the current_version.
      # Not used, only to implement the originating cell's method.
      def diff_renderer
        @diff_renderer ||= renderer_for(current_version)
      end

      # Caches a DiffRenderer instance for the `current_version`.
      def item_diff_renderers
        @item_diff_renderers ||= options[:item_versions].map do |version|
          renderer_for(version)
        end.compact
      end

      def associated_diff_renderers
        @associated_diff_renderers ||= options[:associated_versions].map do |version|
          renderer_for(version)
        end.compact
      end

      def content_diff_renderers
        @content_diff_renderers ||= options[:content_versions].map do |version|
          renderer_for(version)
        end.compact
      end

      def diff_renderers
        item_diff_renderers + associated_diff_renderers + content_diff_renderers
      end

      def renderer_for(version)
        return nil if version.item.nil?

        locale = current_locale unless component_settings.multilingual_answers?

        diff_renderer_class_for(version).new(version, locale)
      end
    end
  end
end
