# frozen_string_literal: true

module Decidim
  module Plans
    module PaperTrail
      class Version < ::PaperTrail::Version
        self.table_name = "versions"

        # Since the test suite has test coverage for this, we want to declare
        # the association when the test suite is running. This makes it pass
        # when DB is not initialized prior to test runs such as when we run on
        # Travis CI Ex. (there won't be a db in `spec/dummy_app/db/`).
        has_many :version_associations,
                 class_name: "Decidim::Plans::PaperTrail::VersionAssociation",
                 dependent: :destroy

        scope(:within_transaction, ->(id) { where transaction_id: id })

        # Track the associations on the plans object
        def track_associations?
          true
        end
      end
    end
  end
end
