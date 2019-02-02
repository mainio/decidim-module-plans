# frozen_string_literal: true

module Decidim
  module Plans
    module PaperTrail
      module RecordTrail
        # Saves associations if
        # a) The version record responds to `track_associations?` and returns
        #    `true` from it.
        # b) `PaperTrail.config.track_associations` is set to `true`.
        def save_associations(version)
          if version.respond_to?(:track_associations?)
            return unless version.track_associations?
          else
            return unless ::PaperTrail.config.track_associations?
          end

          save_bt_associations(version)
          save_habtm_associations(version)
        end
      end
    end
  end
end
