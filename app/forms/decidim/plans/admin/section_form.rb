# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A form object to be used when admin users want to create a plan.
      class SectionForm < Decidim::Form
        include TranslatableAttributes
        include Decidim::ApplicationHelper

        mimic :section

        translatable_attribute :body, String
        translatable_attribute :body_rich, String
        translatable_attribute :help, String
        translatable_attribute :information_label, String
        translatable_attribute :information, String
        attribute :mandatory, Boolean, default: false
        attribute :section_type, String
        attribute :position, Integer
        attribute :deleted, Boolean, default: false

        validates :position, numericality: { greater_than_or_equal_to: 0 }
        validates :body, translatable_presence: true, if: ->(form) { !form.deleted && !form.rich_text_body? }
        validates :body_rich, translatable_presence: true, if: ->(form) { !form.deleted && form.rich_text_body? }

        # Settings attributes for: field_text, field_text_multiline
        attribute :answer_length, Integer, default: 0
        attribute :scope_parent, Integer
        # Settings attributes for: field_area_scope
        attribute :area_scope_parent, Integer
        # Settings attributes for: field_map_point
        attribute :map_center_latitude, Float
        attribute :map_center_longitude, Float
        # Settings attributes for: field_attachments, field_image_attachments
        attribute :attachments_input_type, String
        # Settings attributes for: content
        translatable_attribute :content, String

        with_options if: :requires_answer_length? do
          validates :answer_length, numericality: {
            greater_than_or_equal_to: 0,
            only_integer: true
          }
        end

        with_options if: ->(form) { form.section_type == "field_scope" } do
          validates :scope_parent, numericality: {
            greater_than: 0,
            only_integer: true
          }
        end

        with_options if: ->(form) { form.section_type == "field_area_scope" } do
          validates :area_scope_parent, numericality: {
            greater_than: 0,
            only_integer: true
          }
        end

        with_options if: ->(form) { %w(field_attachments field_image_attachments).include?(form.section_type) } do
          validates :attachments_input_type, inclusion: { in: Section.attachment_input_types }
        end

        def map_model(model)
          case model.section_type
          when "field_text", "field_text_multiline"
            self.answer_length = model.settings["answer_length"].to_i
          when "field_scope"
            self.scope_parent = model.settings["scope_parent"].to_i
          when "field_area_scope"
            self.area_scope_parent = model.settings["area_scope_parent"].to_i
          when "field_map_point"
            self.map_center_latitude = model.settings["map_center_latitude"].to_f
            self.map_center_longitude = model.settings["map_center_longitude"].to_f
          when "field_attachments", "field_image_attachments"
            self.attachments_input_type = model.settings["attachments_input_type"]
          when "content"
            self.body_rich = model.body
          end
        end

        def to_param
          return id if id.present?

          "section-id"
        end

        def body_text
          return body_rich if rich_text_body?

          body
        end

        def rich_text_body?
          section_type == "content"
        end

        def settings
          {}.tap do |hash|
            case section_type
            when "field_text", "field_text_multiline"
              hash[:answer_length] = answer_length
            when "field_scope"
              hash[:scope_parent] = scope_parent
            when "field_area_scope"
              hash[:area_scope_parent] = area_scope_parent
            when "field_map_point"
              hash[:map_center_latitude] = map_center_latitude
              hash[:map_center_longitude] = map_center_longitude
            when "field_attachments", "field_image_attachments"
              hash[:attachments_input_type] = attachments_input_type
            end
          end
        end

        def requires_answer_length?
          %w(field_text field_text_multiline).include?(section_type)
        end
      end
    end
  end
end
