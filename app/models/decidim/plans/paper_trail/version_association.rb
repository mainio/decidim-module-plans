# frozen_string_literal: true

module Decidim
  module Plans
    module PaperTrail
      class VersionAssociation < ApplicationRecord
        self.table_name = "version_associations"

        belongs_to :version,
                   class_name: "Decidim::Plans::PaperTrail::Version"
      end
    end
  end
end
