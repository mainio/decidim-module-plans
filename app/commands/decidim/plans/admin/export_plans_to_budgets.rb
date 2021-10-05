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
              next if plan_already_linked?(original_plan, target_component)

              project = Decidim::Budgets::Project.create!(
                project_attributes_from(original_plan)
              )

              # Create the attachments
              project_attachments_from(original_plan).each do |at|
                Decidim::Attachment.create!(
                  attached_to: project,
                  title: at.title,
                  file: at.file
                )
              end

              # Link included proposals to the project
              proposals = original_plan.linked_resources(:proposals, "included_proposals")
              project.link_resources(proposals, "included_proposals")

              # Link included ideas to the project
              ideas = original_plan.linked_resources(:ideas, "included_ideas")
              project.link_resources(ideas, "included_ideas")

              # Link the plan to the project
              project.link_resources([original_plan], "included_plans")
            end.compact
          end
        end

        def project_attributes_from(original_plan)
          {
            component: target_component,
            budget: project_budget,
            scope: project_scope,
            category: project_category_from(original_plan),
            title: sanitize_localized(original_plan.title),
            description: project_description_from(original_plan),
            budget_amount: project_budget_amount_from(original_plan)
          }.merge(extra_project_attributes_from(original_plan))
        end

        def extra_project_attributes_from(original_plan)
          return {} unless defined?(Decidim::BudgetingPipeline)

          location = project_location_from(original_plan)
          {
            main_image: project_image_from(original_plan),
            summary: sanitize_localized(project_summary_form(original_plan)),
            address: location[:address],
            latitude: location[:latitude],
            longitude: location[:longitude]
          }
        end

        def project_scope
          form.area_scope || form.scope
        end

        def project_budget
          form.target_budget
        end

        def plans
          results = Decidim::Plans::Plan.where(
            component: origin_component
          ).where.not(closed_at: nil)
          if form.scope && scope_section
            scoped_results = scoped_plans_for(scope_section, form.scope)
            results = results.where(id: scoped_results.pluck(:id))
          end
          if form.area_scope && area_scope_section
            area_scoped_results = scoped_plans_for(area_scope_section, form.area_scope)
            results = results.where(id: area_scoped_results.pluck(:id))
          end

          results.accepted
        end

        def scoped_plans_for(section, scope)
          Decidim::Plans::Plan.joins(
            <<~SQL.squish
              LEFT JOIN decidim_plans_sections
                ON decidim_plans_sections.decidim_component_id = decidim_plans_plans.decidim_component_id
                AND decidim_plans_sections.id = #{section.id}
            SQL
          ).joins(
            <<~SQL.squish
              LEFT JOIN decidim_plans_plan_contents AS scope_contents
                ON scope_contents.decidim_plan_id = decidim_plans_plans.id
                AND scope_contents.decidim_section_id = decidim_plans_sections.id
            SQL
          ).where(
            component: origin_component
          ).where(
            "CAST(NULLIF(COALESCE(scope_contents.body->>'scope_id', '0'), '') AS INTEGER) =?",
            scope
          ).group(:id)
        end

        def origin_component
          @form.current_component
        end

        def target_component
          @form.target_component
        end

        def sanitize_localized(hash)
          hash.each do |locale, value|
            hash[locale] = plain_content(value)
          end
        end

        def plan_already_linked?(original_plan, target_component)
          # Search through the resource links manually because the
          # `linked_resources` method won't return any resources if the target
          # component is not published yet.
          original_plan.resource_links_to.where(
            name: "included_plans",
            from_type: "Decidim::Budgets::Project"
          ).any? do |link|
            link.from.component == target_component
          end
        end

        def category_section
          @category_section ||= Decidim::Plans::Section.find_by(
            component: origin_component,
            section_type: "field_category"
          )
        end

        def scope_section
          @scope_section ||= Decidim::Plans::Section.find_by(
            component: origin_component,
            section_type: "field_scope"
          )
        end

        def area_scope_section
          @area_scope_section ||= Decidim::Plans::Section.find_by(
            component: origin_component,
            section_type: "field_area_scope"
          )
        end

        def attachments_section
          @attachments_section ||= Decidim::Plans::Section.find_by(
            component: origin_component,
            section_type: "field_attachments"
          )
        end

        def project_budget_amount_from(original_plan)
          if form.budget_section
            content = original_plan.contents.find_by(section: form.budget_section)
            return content.body["value"].to_f if content && content.body
          end

          form.default_budget_amount
        end

        def project_attachments_from(original_plan)
          return [] unless attachments_section

          content = original_plan.contents.find_by(section: form.budget_section)
          return [] unless content
          return [] unless content.body

          Decidim::Attachment.where(id: content.body["attachment_ids"])
        end

        def project_image_from(original_plan)
          return unless form.image_section

          content = original_plan.contents.find_by(section: form.image_section)
          return {} unless content
          return {} unless content.body

          attachment = Decidim::Attachment.find_by(id: content.body["attachment_ids"].first)
          attachment&.file
        end

        def project_category_from(original_plan)
          return original_plan.category unless category_section

          content = original_plan.contents.find_by(section: category_section)
          return original_plan.category unless content
          return original_plan.category unless content.body

          Decidim::Category.find_by(id: content.body["category_id"]) || original_plan.category
        end

        def project_description_from(original_plan)
          return {} unless form.actual_content_sections

          pr_desc = {}

          # Add content for all sections and languages
          sections = original_plan.sections.where(id: form.actual_content_sections)
          sections.each do |section|
            content = original_plan.contents.find_by(section: section)
            next unless content

            content.body.each do |locale, body_text|
              title = plain_content(section.body[locale])
              pr_desc[locale] ||= ""
              pr_desc[locale] += "<h3>#{title}</h3>\n" if sections.count > 1

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

        def project_summary_form(original_plan)
          return {} unless form.summary_section

          content = original_plan.contents.find_by(section: form.summary_section)
          return {} unless content

          content.body
        end

        def project_location_from(original_plan)
          return {} unless form.location_section

          content = original_plan.contents.find_by(section: form.location_section)
          return {} unless content
          return {} unless content.body

          {
            address: content.body["address"],
            latitude: content.body["latitude"],
            longitude: content.body["longitude"]
          }
        end
      end
    end
  end
end
