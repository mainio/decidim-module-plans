# frozen_string_literal: true

module Decidim
  module Plans
    # A Helper to find and render the author of a version.
    module TraceabilityHelper
      include Decidim::TraceabilityHelper

      # Caches a DiffRenderer instance for the `current_version`.
      def item_diff_renderers
        @item_diff_renderers ||= item_versions.map do |version|
          renderer_for(version)
        end.compact
      end

      def associated_diff_renderers
        @associated_diff_renderers ||= associated_versions.map do |version|
          renderer_for(version)
        end.compact
      end

      def content_diff_renderers
        @content_diff_renderers ||= content_versions.map do |version|
          renderer_for(version)
        end.compact
      end

      def diff_renderers
        item_diff_renderers + associated_diff_renderers + content_diff_renderers
      end

      private

      def renderer_for(version)
        locale = current_locale unless component_settings.multilingual_answers?

        renderer_klass =
          case version.item.class.name
          when "Decidim::Plans::Plan"
            Decidim::Plans::DiffRenderer::Plan
          when "Decidim::Plans::Content"
            Decidim::Plans::DiffRenderer::Content
          when "Decidim::Categorization"
            Decidim::Plans::DiffRenderer::Categorization
          when "Decidim::Component"
            Decidim::Plans::DiffRenderer::Component
          end

        renderer_klass.new(version, locale)
      end

      # Renders the given value in a user-friendly way based on the value class.
      #
      # value - an object to be rendered
      #
      # Returns an HTML-ready String.
      def render_diff_value(value, type, action, options = {})
        return "".html_safe if value.blank?

        value_to_render = case type
                          when :date
                            l value, format: :long
                          when :percentage
                            number_to_percentage value, precision: 2
                          when :translatable
                            value.to_s
                          else
                            value
                          end

        content_tag(:div, class: "card--list__item #{action}") do
          content_tag(:div, class: "card--list__text") do
            content_tag(:div, { class: "diff__value" }.merge(options)) do
              value_to_render
            end
          end
        end
      end
    end
  end
end
