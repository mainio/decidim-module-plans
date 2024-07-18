# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # This controller is the abstract class from which all other controllers of
      # this engine inherit.
      #
      # Note that it inherits from `Decidim::Admin::Components::BaseController`, which
      # override its layout and provide all kinds of useful methods.
      class ApplicationController < Decidim::Admin::Components::BaseController
        include Decidim::ApplicationHelper

        helper Decidim::ApplicationHelper
      end
    end
  end
end
