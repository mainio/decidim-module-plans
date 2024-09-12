# frozen_string_literal: true

require "cell/partial"

module Decidim
  module Plans
    # This cell renders a plan with its M-size card.
    class PlanGCell < Decidim::CardGCell
      include PlanCellsHelper
      include Decidim::Plans::CellContentHelper

      alias plan model

      def badge
        render if has_badge?
      end

      private

      def card_wrapper
        wrapper_options = { class: "card", aria: { label: t(".card_label", title:) } }
        if has_link_to_resource?
          link_to resource_path, **wrapper_options do
            yield
          end
        else
          aria_options = { role: "region" }
          content_tag :div, **aria_options.merge(wrapper_options) do
            yield
          end
        end
      end

      def preview?
        options[:preview]
      end

      def render_column?
        !context[:no_column].presence
      end

      def show_favorite_button?
        !context[:disable_favorite].presence
      end

      # Don't display the authors on the card.
      def has_authors?
        false
      end

      def title
        decidim_html_escape(present(model).title)
      end

      def body
        decidim_sanitize(present(model).body_contents)
      end

      def category_name
        translated_attribute(category.name) if has_category?
      end

      def full_category
        return unless has_category?

        parts = []
        parts << translated_attribute(category.parent.name) if category.parent
        parts << category_name

        parts.join(" - ")
      end

      def category_class
        "card__category--#{category.id}" if has_category?
      end

      def has_state?
        model.published?
      end

      def published_state?
        answered?
      end

      def has_badge?
        closed? || answered? || withdrawn?
      end

      def has_link_to_resource?
        model.published?
      end

      def has_footer?
        true
      end

      def badge_classes
        return super unless options[:full_badge]

        state_classes.push(["label", "idea-status"]).join(" ")
      end

      def statuses
        return [] if preview?
        return [:comments_count] if model.draft?

        [:comments_count, :favoriting_count]
      end

      def comments_count_status
        render_comments_count
      end

      # def creation_date_status
      #   l(model.published_at.to_date, format: :decidim_short)
      # end

      def favoriting_count_status
        cell("decidim/favorites/favoriting_count", model)
      end

      def category_icon
        cat = icon_category
        return unless cat

        content_tag(:span, class: "card__category__icon", "aria-hidden": true) do
          image_tag(cat.attached_uploader(:category_icon).path, alt: full_category)
        end
      end

      def category_style
        cat = color_category
        return unless cat

        "background-color:#{cat.color};"
      end

      def resource_utm_params
        return {} unless context[:utm_params]

        context[:utm_params].transform_keys do |key|
          "utm_#{key}"
        end
      end

      def resource_path
        resource_locator(model).path + request_params_query(resource_utm_params)
      end

      def description
        model_body = strip_tags(body)

        if options[:full_description]
          model_body.gsub(/\n/, "<br>")
        else
          truncate(model_body, length: 100)
        end
      end

      def has_image?
        return false unless image_section

        plan_image.present? && plan_image.file.content_type.start_with?("image")
      end

      def image_section
        @image_section ||= first_section_with_type("field_image_attachments")
      end

      def image_content
        @image_content ||= content_for(image_section)
      end

      def plan_image
        return unless image_content
        return if image_content.body["attachment_ids"].blank?

        @plan_image ||= Decidim::Attachment.find_by(
          id: image_content.body["attachment_ids"].first
        )
      end

      def default_plan_image
        Decidim::Plans.default_card_image
      end

      def resource_image_path
        return plan_image.attached_uploader(:file).path(variant: resource_image_variant) if has_image?

        if has_category?
          path = category_image_path(category)
          path = category_image_path(category.parent) if !path && category.parent.present?

          return path if path
        end

        default_plan_image
      end

      def resource_image_variant
        :thumbnail
      end

      def category_image_path(cat)
        return unless has_category?
        return unless cat.respond_to?(:category_image)
        return unless cat.category_image
        return unless cat.category_image.attached?

        cat.attached_uploader(:category_image).path(variant: category_image_variant)
      end

      def category_image_variant
        :card
      end

      def icon_category(cat = nil)
        return unless has_category?

        cat ||= category
        return unless cat.respond_to?(:category_icon)
        return cat if cat.category_icon && cat.category_icon.attached?
        return unless cat.parent

        icon_category(cat.parent)
      end

      def color_category(cat = nil)
        return unless has_category?

        cat ||= category
        return unless cat.respond_to?(:color)
        return cat if cat.color
        return unless cat.parent

        color_category(cat.parent)
      end
    end
  end
end
