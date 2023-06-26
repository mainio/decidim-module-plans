# frozen_string_literal: true

module Decidim
  module Plans
    # This class acts as a manifest for section types.
    #
    # A section type is a view section related to a plans component. Each plan
    # may have multiple sections and the section type defines what each section
    # looks like. Section can be e.g. static content, editable text, map point
    # or anything else related to a plan object.
    #
    # A section type has a set of settings, such as the cell that controls the
    # section's form and display elements and the form object which controls the
    # data that the user sends to the cell. The section also has an associated
    # command object which can be used to store the data for the associated
    # content element.
    class SectionTypeManifest
      include ActiveModel::Model
      include Virtus.model

      attribute :name, Symbol
      attribute :edit_cell, String, default: "decidim/plans/section_edit"
      attribute :display_cell, String, default: "decidim/plans/section_display"
      attribute :content_form_class_name, String, default: "Decidim::Plans::ContentData::BaseForm"
      attribute :content_control_class_name, String, default: "Decidim::Plans::SectionControl::Base"
      attribute :api_type_class_name, String, default: "Decidim::Plans::SectionContent::FieldTextType"

      validates :name, presence: true

      # Public: Finds the content form class from its name, using the
      # `content_form_class_name` attribute. If the class does not exist, it
      # raises an exception. If the class name is not set, it returns nil.
      #
      # Returns a Decidim::Plans::ContentForm::ContentData or its subclass.
      def content_form_class
        content_form_class_name&.constantize
      end

      # Public: Finds the content control class from its name, using the
      # `content_control_class_name` attribute. If the class does not exist, it
      # raises an exception. If the class name is not set, it returns nil.
      #
      # Returns a Decidim::Plans::SectionControl::Base or its subclass.
      def content_control_class
        content_control_class_name&.constantize
      end

      # Public: Finds the API type class from its name, using the
      # `api_type_class_name` attribute. If the class does not exist, it
      # raises an exception. If the class name is not set, it returns nil.
      #
      # Returns a subclass of GraphQL::Schema::Object.
      def api_type_class
        api_type_class_name&.constantize
      end
    end
  end
end
