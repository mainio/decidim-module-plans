# frozen_string_literal: true

module Decidim
  module Plans
    module ContentData
      # A form object for actual content form objects to extend from.
      class BaseForm < Decidim::Form
        include Decidim::TranslatableAttributes

        alias component current_component

        attribute :section_id, Integer
        attribute :plan_id, Integer

        attr_writer :section, :plan

        delegate :mandatory, :section_type_manifest, to: :section

        def initialize(attributes = nil)
          # The section definition is already needed when setting the other
          # attributes in order to fetch the section settings.
          self.section_id = attributes[:section_id] if attributes && attributes[:section_id]

          super
        end

        def section
          @section ||= Decidim::Plans::Section.find(section_id)
        end

        def control
          @control ||= section.section_type_manifest.content_control_class.new(self)
        end

        def plan
          @plan ||= Decidim::Plans::Plan.find(plan_id)
        end

        def label
          translated_attribute(section.body)
        end

        def help
          translated_attribute(section.help)
        end

        def information_label
          translated_attribute(section.information_label)
        end

        # Public: Map the correct fields.
        #
        # Returns nothing.
        def map_model(model)
          self.section_id = model.decidim_section_id
          self.section = model.section

          self.plan_id = model.decidim_plan_id
          self.plan = model.plan
        end

        def deleted?
          false
        end
      end
    end
  end
end
