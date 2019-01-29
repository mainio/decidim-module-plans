# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This command is executed when the user modifies sections from
      # the admin panel.
      class UpdateSections < Rectify::Command
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
                body: form_section.body,
                help: form_section.help,
                mandatory: form_section.mandatory,
                position: form_section.position
              },
              @sections
            )
          end
        end
      end
    end
  end
end
