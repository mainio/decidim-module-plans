# frozen_string_literal: true

module Decidim
  module Plans
    module SectionTypeDisplay
      class FieldAttachmentsCell < Decidim::Plans::SectionDisplayCell
        include ActionView::Helpers::NumberHelper
        include Cell::ViewModel::Partial
        include ERB::Util
        include Decidim::AttachmentsHelper
        include Decidim::LayoutHelper # For the icon helper

        def show
          return if attachments.blank?

          render
        end

        private

        def attachments
          return [] unless model.body["attachment_ids"]

          @attachments ||= Decidim::Attachment.where(
            id: model.body["attachment_ids"]
          )
        end

        def documents
          @documents ||= attachments.includes(:attachment_collection).select(&:document?)
        end

        def photos
          @photos ||= attachments.select(&:photo?)
        end
      end
    end
  end
end
