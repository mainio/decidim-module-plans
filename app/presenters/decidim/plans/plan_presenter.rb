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
        translated_attribute(plan.title).html_safe
      end

      def body
        fields = plan.sections.map do |section|
          content = plan.contents.find_by(section: section)
          next if content.nil?

          title = translated_attribute(content.title)
          body = translated_attribute(content.body)
          "<dt>#{title}</dt> <dd>#{body}</dd>"
        end

        "<dl>#{fields.join("\n")}</dl>".html_safe
      end
    end
  end
end
