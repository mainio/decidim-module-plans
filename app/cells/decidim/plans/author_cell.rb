# frozen_string_literal: true

module Decidim
  module Plans
    class AuthorCell < Decidim::AuthorCell
      include Plans::CellsHelper

      private

      def withdraw_path
        from_context_path + "/withdraw"
      end
    end
  end
end
