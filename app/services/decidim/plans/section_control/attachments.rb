# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object for attachments field type.
      class Attachments < Base
        def prepare!(plan)
          self.class.clear_total_weight
          return unless attachments_present?

          attachments_valid?(plan)
        end

        def save!(plan)
          return unless attachments_present?

          @attachments = form.attachments.map do |attachment|
            next if attachment.deleted?

            store_attachment!(
              plan,
              attachment,
              attachment_params(plan, attachment)
            )
          end

          # The class attachments weight takes care of the attachments weight
          # for the whole plan object as there can be multiple attachments
          # sections. This increases the following sections' weight so that they
          # will come after the attachments in this section.
          self.class.increase_total_weight_by(attachments.count)

          super
        end

        def finalize!(_plan)
          self.class.clear_total_weight

          true
        end

        def fail!(_plan)
          return unless attachments_present?

          # Mark attachments for re-attachment
          form.attachments.each do |at|
            at.errors.add(:file, :needs_to_be_reattached) if at.file.present? && at.id.blank?
          end
        end

        def self.clear_total_weight
          self.total_weight = 0
        end

        def self.increase_total_weight_by(amount)
          self.total_weight += amount
        end

        private

        cattr_accessor :total_weight

        attr_reader :attachments

        def body_attribute
          { attachment_ids: attachments.compact.map(&:id) }
        end

        def attachments_present?
          @attachments_present ||= form.attachments.any? do |at|
            at.title.present? || at.file.present? || at.id.present?
          end
        end

        def store_attachment!(plan, atform, attributes)
          record = plan.attachments.find_by(id: atform.id) || plan.attachments.build(attributes)

          if record.persisted?
            if atform.deleted?
              record.destroy!
            else
              record.update!(attributes)
            end
          elsif !atform.deleted?
            record.save!
          end

          record
        end

        def attachments_valid?(plan)
          @attachments_valid ||= begin
            form.attachments.each do |atform|
              next if atform.deleted?
              next unless atform.valid?

              attachment = begin
                if atform.id.present?
                  Attachment.find(atform.id)
                else
                  Attachment.new
                end
              end
              attachment.assign_attributes(attachment_params(plan, atform))

              next if attachment.valid? || !attachment.errors.has_key?(:file)

              atform.errors.add :file, attachment.errors[:file]
            end

            form.attachments.none? { |at| at.errors.any? }
          end
        end

        def attachment_params(plan, atform)
          params = {
            weight: self.class.total_weight + atform.weight,
            title: { I18n.locale => atform.title },
            attached_to: plan
          }
          params[:file] = atform.file if atform.file.present?

          params
        end
      end
    end
  end
end
