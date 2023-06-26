# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::ExportPlansToBudgets do
  let(:form_klass) { Decidim::Plans::Admin::PlanExportBudgetsForm }

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:participatory_space) { component.participatory_space }

  let(:target_component) { create(:budgets_component, participatory_space: participatory_space) }
  let(:budget) { create(:budget, component: target_component) }

  let(:user) { create :user, :admin, :confirmed, organization: organization }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_component: component,
      current_participatory_space: participatory_space
    )
  end

  let!(:plans) { create_list :plan, 10, :published, :accepted, closed_at: Time.current, component: component }

  describe "call" do
    let(:form_params) do
      {
        target_component_id: target_component.try(:id),
        target_details: [
          { component_id: target_component.try(:id), budget_id: budget.try(:id) }
        ],
        default_budget_amount: 50_000,
        export_all_closed_plans: true
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
            component: component
          )
        end

        before do
          section = create(
            :section,
            component: component,
            body: Decidim::Faker::Localized.localized { malicious_content }
          )

          plans.each do |plan|
            create(
              :content,
              plan: plan,
              section: section,
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
