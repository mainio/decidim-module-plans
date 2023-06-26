# frozen_string_literal: true

module Decidim
  module ContentParsers
    # A parser that searches mentions of Plans in content.
    #
    # This parser accepts one way for linking Plans:
    # - Using a standard url starting with http or https.
    #
    # Also fills a `Metadata#linked_plans` attribute.
    #
    # @see BaseParser Examples of how to use a content parser
    class PlanParser < BaseParser
      # Class used as a container for metadata
      #
      # @!attribute linked_plans
      #   @return [Array] an array of Decidim::Plans::Plan mentioned in content
      Metadata = Struct.new(:linked_plans)

      # Matches a URL
      URL_REGEX_SCHEME = '(?:http(s)?:\/\/)'
      URL_REGEX_CONTENT = '[\w.-]+[\w\-\._~:\/?#\[\]@!\$&\'\(\)\*\+,;=.]+'
      URL_REGEX_END_CHAR = '[\d]'
      URL_REGEX = %r{#{URL_REGEX_SCHEME}#{URL_REGEX_CONTENT}/plans/#{URL_REGEX_END_CHAR}+}i.freeze
      # Matches a mentioned Proposal ID (~(d)+ expression)
      ID_REGEX = /~(\d+)/.freeze

      def initialize(content, context)
        super
        @metadata = Metadata.new([])
      end

      # Replaces found mentions matching an existing Plan with a global id for
      # that Plan. Other mentions found that doesn't match an existing Plan
      # are returned as they are.
      #
      # @return [String] the content with the valid mentions replaced by a
      #                  global id.
      def rewrite
        parse_for_urls(content)
      end

      # (see BaseParser#metadata)
      attr_reader :metadata

      private

      def parse_for_urls(content)
        content.gsub(URL_REGEX) do |match|
          plan = plan_from_url_match(match)
          if plan
            @metadata.linked_plans << plan.id
            plan.to_global_id
          else
            match
          end
        end
      end

      def plan_from_url_match(match)
        uri = URI.parse(match)
        return if uri.path.blank?

        plan_id = uri.path.split("/").last
        find_plan_by_id(plan_id)
      rescue URI::InvalidURIError
        Rails.logger.error("#{e.message}=>#{e.backtrace}")
        nil
      end

      def find_plan_by_id(id)
        if id.present?
          spaces = Decidim.participatory_space_manifests.flat_map do |manifest|
            manifest.participatory_spaces.call(context[:current_organization]).public_spaces
          end
          components = Component.where(participatory_space: spaces).published
          Decidim::Plans::Plan.where(component: components).find_by(id: id)
        end
      end
    end
  end
end
