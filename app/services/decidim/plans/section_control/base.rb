# frozen_string_literal: true

module Decidim
  module Plans
    module SectionControl
      # A section control object takes care of preparing the content forms for
      # storing the records as well as creating and updating the content
      # records for the sections. This is needed because some sections require
      # either prepration or post processing procedures during the saving
      # process.
      class Base
        def initialize(form)
          @form = form
        end

        def content_for(plan)
          return nil unless plan

          @content ||= begin
            plan.contents.find_by(id: form.id) || plan.contents.build
          end
        end

        # Prepare is called when the base plan is saved and saving the contents
        # starts.
        def prepare!(plan); end

        # Save is called when the form is validated and all values should be
        # valid. This is where the content elements should be created or
        # updated.
        def save!(plan)
          content = content_for(plan)
          return false unless content

          content.attributes = attributes
          content.save!
        end

        # Finalize is called after all content records have been successfully
        # saved and before the response is broadcast back to the controller.
        def finalize!(plan); end

        # Fail is called when some of the fields have invalid values and the
        # form saving fails before saving any values. It could be also called
        # if preparing, saving or finalizing of one of the content records
        # fails due to an exception (StandardError).
        def fail!(plan); end

        private

        attr_reader :form

        def attributes
          {
            body: body_attribute,
            section: form.section,
            user: form.current_user
          }
        end

        def body_attribute
          form.body
        end
      end
    end
  end
end
