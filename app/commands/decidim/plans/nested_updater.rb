# frozen_string_literal: true

module Decidim
  module Plans
    # Updater for nested models.
    module NestedUpdater
      private

      def update_nested_model(form, attributes, parent_association)
        record = parent_association.find_by(id: form.id) || parent_association.build(attributes)

        yield record if block_given?

        if record.persisted?
          if form.deleted?
            record.destroy!
          else
            record.update!(attributes)
          end
        elsif !form.deleted?
          record.save!
        end
      end
    end
  end
end
