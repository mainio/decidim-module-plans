# frozen_string_literal: true

module Decidim
  module Plans
    class PlanFormCell < Decidim::ViewModel
      include Decidim::Plans::ApplicationHelper
      include ActionView::Helpers::FormOptionsHelper

      delegate(
        :current_user,
        :user_signed_in?,
        :component_settings,
        :current_component,
        :snippets,
        to: :controller
      )

      def user_group_field
        return if options[:disable_user_group_field]
        return unless manageable_user_groups.any?

        render :user_group_field
      end

      def contents_edit
        render :contents_edit
      end

      private

      def display_save_as_draft?
        plan.blank? || plan.draft?
      end

      def display_discard?
        plan && plan.persisted? && plan.draft?
      end

      def form
        model
      end

      def plan
        context[:plan]
      end

      def plan_path(plan, options = {})
        return "#" unless plan

        Decidim::ResourceLocatorPresenter.new(plan).path(options)
      end

      def object
        form.object
      end

      def manageable_user_groups
        @manageable_user_groups ||= Decidim::UserGroups::ManageableUserGroups.for(current_user).verified
      end

      # Renders a user_group select field in a form.
      # form - FormBuilder object
      # name - attribute user_group_id
      #
      # Returns nothing.
      def user_group_select_field(name)
        selected = object.user_group_id.presence
        form.select(
          name,
          manageable_user_groups.map { |g| [g.name, g.id] },
          selected: selected,
          include_blank: current_user.name
        )
      end

      def current_locale
        I18n.locale.to_s
      end
    end
  end
end
