# frozen_string_literal: true

module Decidim
  module Plans
    # A module with all the common content related methods for plan commands.
    module PlanContentMethods
      private

      def prepare_plan_contents
        @form.contents.each do |content|
          content.control.prepare!(plan)
        end
      rescue StandardError => e
        fail_plan_contents
        raise e
      end

      def save_plan_contents
        @form.contents.each do |content|
          content.control.save!(plan)
        end
      rescue StandardError => e
        fail_plan_contents
        raise e
      end

      def finalize_plan_contents
        @form.contents.each do |content|
          content.control.finalize!(plan)
        end
      rescue StandardError => e
        fail_plan_contents
        raise e
      end

      def fail_plan_contents
        @form.contents.each do |content|
          content.control.fail!(plan)
        end
      end
    end
  end
end
