# frozen_string_literal: true

module Decidim
  module Plans
    #
    # Decorator for plans
    #
    class PlanPresenter < SimpleDelegator
      include Rails.application.routes.mounted_helpers
      include ActionView::Helpers::UrlHelper
      include TranslatableAttributes
      include Plans::RichPresenter

      def author
        coauthorship = coauthorships.first
        @author ||= if coauthorship.user_group
                      Decidim::UserGroupPresenter.new(coauthorship.user_group)
                    else
                      Decidim::UserPresenter.new(coauthorship.author)
                    end
      end

      def plan
        __getobj__
      end

      def plan_path
        Decidim::ResourceLocatorPresenter.new(plan).path
      end

      def title
        plain_content(translated_attribute(plan.title))
      end

      def body
        fields = plan.sections.map do |section|
          content = plan.contents.find_by(section: section)
          next if content.nil?

          section_title = plain_content(translated_attribute(content.title))
          section_body = plain_content(translated_attribute(content.body))
          "<dt>#{section_title}</dt> <dd>#{section_body}</dd>"
        end

        "<dl>#{fields.join("\n")}</dl>".html_safe
      end
    end
  end
end
