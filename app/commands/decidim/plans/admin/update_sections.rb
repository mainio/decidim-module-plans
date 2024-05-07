# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This command is executed when the user modifies sections from
      # the admin panel.
      class UpdateSections < Decidim::Command
        include NestedUpdater

        # Initializes a UpdateSections Command.
        #
        # form - The form from which to get the data.
        # sections - The current set of the sections to be updated.
        def initialize(form, sections)
          @form = form
          @sections = sections
        end

        # Updates the sections if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        def call
          return broadcast(:invalid) if @form.invalid?

          Decidim::Plans::Section.transaction do
            update_sections
          end

          broadcast(:ok)
        end

        private

        def update_sections
          @form.sections.each do |form_section|
            update_nested_model(
              form_section,
              {
                handle: form_section.handle,
                body: form_section.body_text,
                help: form_section.help,
                error_text: form_section.error_text,
                information_label: form_section.information_label,
                information: form_section.information,
                mandatory: form_section.mandatory,
                searchable: form_section.searchable,
                position: form_section.position,
                section_type: form_section.section_type,
                visible_form: form_section.visible_form,
                visible_view: form_section.visible_view,
                visible_api: form_section.visible_api,
                settings: form_section.settings
              },
              @sections
            )
          end
        end
      end
    end
  end
end
