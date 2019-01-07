# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This command is executed when the user modifies sections from
      # the admin panel.
      class UpdateSections < Rectify::Command
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
            update_section(form_section)
          end
        end

        def update_section(form_section)
          section_attributes = {
            body: form_section.body,
            position: form_section.position
          }

          record = @sections.find_by(id: form_section.id) || @sections.build(section_attributes)

          if record.persisted?
            if form_section.deleted?
              record.destroy!
            else
              record.update!(section_attributes)
            end
          else
            record.save!
          end
        end
      end
    end
  end
end
