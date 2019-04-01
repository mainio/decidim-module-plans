# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when a user destroys a tag.
      class DestroyTag < Rectify::Command
        # Public: Initializes the command.
        #
        # tag - The target object to be destroyed.
        # current_user - the user performing the action.
        def initialize(tag, current_user)
          @tag = tag
          @current_user = current_user
        end

        # Destroys the tag if valid.
        #
        # Broadcasts :ok if successful, :invalid otherwise.
        #
        # Returns nothing.
        def call
          destroy_tag

          broadcast(:ok)
        end

        private

        attr_reader :tag, :current_user

        def destroy_tag
          Decidim.traceability.perform_action!(
            :delete,
            tag,
            current_user
          ) do
            tag.destroy!
          end
        end
      end
    end
  end
end
