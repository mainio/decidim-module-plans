# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when admin users want to create or edit
    # a plan content field.
    class ContentForm < Decidim::Form
      # mimic :content

      def self.from_model(model)
        form_class_for(model.decidim_section_id).from_model(model)
      end

      def self.from_params(params, additional_params = {})
        form_class_for(params[:section_id]).from_params(params, additional_params)
      end

      def self.form_class_for(section_id)
        section = Decidim::Plans::Section.find_by(id: section_id) if section_id

        if section
          section.section_type_manifest.content_form_class
        else
          Decidim::Plans::ContentData::BaseForm
        end
      end
    end
  end
end
