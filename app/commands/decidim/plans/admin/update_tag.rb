# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user updates a tag.
      class UpdateTag < Rectify::Command
        # Public: Initializes the command.
        #
        # form - A form object with the params.
        # tag - The target object to be updated.
        def initialize(form, tag)
          @form = form
          @tag = tag
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid, together with the plan.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if form.invalid?

          update_tag

          broadcast(:ok, tag)
        end

        private

        attr_reader :form, :tag

        def update_tag
          Decidim.traceability.perform_action!(
            :update,
            tag,
            form.current_user
          ) do
            tag.update!(name: form.name)
          end
        end
      end
    end
  end
end
