# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user creates a new tag.
      class CreateTag < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the tag.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          create_tag

          broadcast(:ok, tag)
        end

        private

        attr_reader :form, :tag

        def create_tag
          @tag = Decidim.traceability.create(
            Tag,
            form.current_user,
            name: form.name,
            organization: form.organization
          )
        end
      end
    end
  end
end
