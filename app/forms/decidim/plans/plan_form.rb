# frozen_string_literal: true

module Decidim
  module Plans
    # A form object to be used when public users want to create a Plan.
    class PlanForm < Decidim::Form
      include OptionallyTranslatableAttributes
      mimic :plan

      alias component current_component

      attribute :user_group_id, Integer
      attribute :contents, Array

      def self.from_params(params, additional_params = {})
        form = super
        form.contents = form.contents.map do |section_params|
          ContentForm.from_params(section_params, additional_params)
        end

        form
      end

      def map_model(model)
        self.contents = model.sections.visible_in_form.map do |section|
          ContentForm.from_model(
            Content
              .where(plan: model, section: section)
              .first_or_initialize(plan: model, section: section, body: {})
          )
        end

        self.user_group_id = model.user_groups.first&.id
      end

      def user_group
        @user_group ||= Decidim::UserGroup.find user_group_id if user_group_id.present?
      end

      def valid?(options = {})
        base_valid = super

        contents.all? { |cf| cf.valid?(options) } && base_valid
      end
    end
  end
end
