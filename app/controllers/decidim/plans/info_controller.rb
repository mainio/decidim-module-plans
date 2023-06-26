# frozen_string_literal: true

module Decidim
  module Plans
    class InfoController < Decidim::Plans::ApplicationController
      include Decidim::ApplicationHelper

      def show
        raise ActionController::RoutingError, "Not found" unless section

        @text = translated_attribute(section.information)

        headers["X-Robots-Tag"] = "none"

        respond_to do |format|
          format.html
          format.json { render json: { text: @text } }
        end
      end

      private

      def section
        @section ||= Decidim::Plans::Section.find_by(id: params[:section])
      end
    end
  end
end
