# frozen_string_literal: true

module Decidim
  module Plans
    #
    # A dummy presenter to abstract out the author of an official resource.
    #
    class OrganizationAuthorPresenter < SimpleDelegator
      def nickname
        ""
      end

      def badge
        ""
      end

      def profile_path
        ""
      end

      def avatar_url
        Decidim::AvatarUploader.new.default_url
      end

      def deleted?
        false
      end

      def can_be_contacted?
        false
      end

      def has_tooltip?
        false
      end
    end
  end
end
