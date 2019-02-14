# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module PaperTrail
      describe VersionAssociation do
        it { is_expected.to respond_to(:version) }
      end
    end
  end
end
