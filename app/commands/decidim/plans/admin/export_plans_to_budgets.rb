# frozen_string_literal: true

module Decidim
  module Plans
    module Admin
      # A command with all the business logic when an admin exports plans to a
      # single budget component.
      class ExportPlansToBudgets < Rectify::Command
        include Decidim::Plans::RichPresenter

        # Public: Initializes the command.
        #
        # form - A form object with the params.
        def initialize(form)
          @form = form
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the form wasn't valid and we couldn't proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) unless @form.valid?

          broadcast(:ok, create_projects_from_closed_plans)
        end

        private

        attr_reader :form

        def create_projects_from_closed_plans
          transaction do
            plans.map do |original_plan|
              next if plan_already_copied?(original_plan, target_component)

              project = Decidim::Budgets::Project.new
              project.budget = form.details.target_budget
              project.scope = original_plan.scope
              project.category = original_plan.category
              project.title = sanitize_localized(original_plan.title)
              project.description = project_description(original_plan)
              project.budget_amount = form.default_budget_amount
              project.component = target_component
              project.save!

              # Create the attachments
              original_plan.attachments.each do |at|
                Decidim::Attachment.create!(
                  attached_to: project,
                  title: at.title,
                  file: at.file
                )
              end

              # Link included proposals to the project
              proposals = original_plan.linked_resources(:proposals, "included_proposals")
              project.link_resources(proposals, "included_proposals")

              # Link the plan to the project
              project.link_resources([original_plan], "included_plans")
            end.compact
          end
        end

        def plans
          results = Decidim::Plans::Plan.where(
            component: origin_component
          ).where.not(closed_at: nil)
          return results.where(scope: @form.scope) if @form.scope

          results
        end

        def origin_component
          @form.current_component
        end

        def target_component
          @form.target_component
        end

        def plan_already_copied?(original_plan, target_component)
          original_plan.linked_resources(:projects, "included_plans").any? do |plan|
            plan.component == target_component
          end
        end

        def project_description(original_plan)
          pr_desc = {}

          # Add content for all sections and languages
          export_types = %w(field_text field_text_multiline)
          original_plan.sections.each do |section|
            next unless export_types.include?(section.section_type)

            content = original_plan.contents.find_by(section: section)
            next unless content

            content.body.each do |locale, body_text|
              title = plain_content(section.body[locale])
              pr_desc[locale] ||= ""
              pr_desc[locale] += "<h3>#{title}</h3>\n"

              # Wrap non-HTML strings within a <p> tag and replace newlines with
              # <br>. This also takes care of sanitization and specific styling
              # of the text, such as bold, italics, etc.
              pr_desc[locale] += rich_content(body_text)
            end
          end

          # Cleanup the unnecessary whitespace
          pr_desc.each_value(&:strip!)

          pr_desc
        end

        def sanitize_localized(hash)
          hash.each do |locale, value|
            hash[locale] = plain_content(value)
          end
        end
      end
    end
  end
end
