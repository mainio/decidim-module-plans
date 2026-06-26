# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::ExportPlansToBudgets do
  let(:form_klass) { Decidim::Plans::Admin::PlanExportBudgetsForm }

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:participatory_space) { component.participatory_space }

  let(:sections) { create_list(:section, 2, :field_text, component:) }

  let(:target_component) { create(:budgets_component, participatory_space:) }
  let(:budget) { create(:budget, component: target_component) }

  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_component: component,
      current_participatory_space: participatory_space
    )
  end

  let!(:plans) { create_list(:plan, 10, :published, :accepted, closed_at: Time.current, component:) }

  describe "call" do
    let(:sections_param) { sections.map(&:id) }
    let(:form_params) do
      {
        target_component_id: target_component.try(:id),
        content_sections: sections_param,
        target_details: [
          { component_id: target_component.try(:id), budget_id: budget.try(:id) }
        ],
        default_budget_amount: 50_000,
        export_all_closed_plans: true,
        taxonomy_ids: []
      }
    end

    let(:command) do
      described_class.new(form)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:valid?).and_return(false)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't add the projects" do
        expect do
          command.call
        end.not_to change(Decidim::Budgets::Project, :count)
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "adds the answer" do
        expect do
          command.call
        end.to change(Decidim::Budgets::Project, :count).by(10)
      end

      context "when filtering by taxonomy" do
        let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
        let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
        let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }

        let(:form_params) do
          {
            target_component_id: target_component.try(:id),
            content_sections: sections_param,
            target_details: [
              { component_id: target_component.try(:id), budget_id: budget.try(:id) }
            ],
            default_budget_amount: 50_000,
            export_all_closed_plans: true,
            taxonomy_ids: [taxonomy.id.to_s]
          }
        end

        before do
          # Tag only 3 plans with the selected taxonomy
          plans.first(3).each do |plan|
            plan.taxonomizations.find_or_create_by(taxonomy:)
          end
          # Tag 2 plans with a different taxonomy (should not be exported)
          plans.last(2).each do |plan|
            plan.taxonomizations.find_or_create_by(taxonomy: other_taxonomy)
          end
        end

        it "only exports plans with the selected taxonomy" do
          expect { command.call }.to change(Decidim::Budgets::Project, :count).by(3)
        end

        it "copies taxonomizations to the exported projects" do
          command.call
          Decidim::Budgets::Project.all.each do |project|
            expect(project.taxonomizations.pluck(:taxonomy_id)).to include(taxonomy.id)
          end
        end
      end

      context "when no taxonomy filter is applied" do
        it "exports all accepted closed plans" do
          expect { command.call }.to change(Decidim::Budgets::Project, :count).by(10)
        end

        it "does not create any taxonomizations on projects" do
          command.call
          expect(Decidim::Budgets::Project.all.flat_map(&:taxonomizations)).to be_empty
        end
      end

      context "when the plans contain malicious HTML" do
        let(:malicious_content_array) do
          [
            "<script>alert('XSS');</script>",
            "<img src='https://www.decidim.org'>",
            "<a href='http://www.decidim.org'>Link</a>"
          ]
        end
        let(:malicious_content) { malicious_content_array.join("\n") }

        let!(:plans) do
          create_list(
            :plan,
            10,
            :published,
            title: Decidim::Faker::Localized.localized { malicious_content },
            closed_at: Time.current,
            component:
          )
        end

        before do
          section = create(
            :section,
            component:,
            body: Decidim::Faker::Localized.localized { malicious_content }
          )

          plans.each do |plan|
            create(
              :content,
              plan:,
              section:,
              body: Decidim::Faker::Localized.localized { malicious_content }
            )
          end
        end

        it "sanitizes the malicious content" do
          command.call

          Decidim::Budgets::Project.all.each do |project|
            malicious_content_array.each do |mc|
              expect(project.title).not_to include(mc)
              expect(project.description).not_to include(mc)
            end
          end
        end
      end
    end
  end
end
