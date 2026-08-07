# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe CreatePlan do
        let(:form_klass) { PlanForm }
        let(:component) { create(:plan_component) }
        let(:organization) { component.organization }
        let(:user) { create(:user, :admin, :confirmed, organization:) }
        let(:form) do
          form_klass.from_params(
            form_params
          ).with_context(
            current_user: user,
            current_organization: organization,
            current_participatory_space: component.participatory_space,
            current_component: component
          )
        end
        let(:attachment_params) { nil }

        describe "call" do
          let(:form_params) do
            {
              user_group_id: nil
            }
          end

          let(:command) do
            described_class.new(form)
          end

          describe "when the form is not valid" do
            before do
              allow(form).to receive(:invalid?).and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create a plan" do
              expect do
                command.call
              end.not_to change(Decidim::Plans::Plan, :count)
            end
          end

          describe "when the form is valid" do
            it "broadcasts ok" do
              expect { command.call }.to broadcast(:ok)
            end

            it "creates a new plan" do
              expect do
                command.call
              end.to change(Decidim::Plans::Plan, :count).by(1)
            end

            it "sets the organization as author" do
              command.call

              expect(Decidim::Plans::Plan.last.authors).to include(organization)
            end

            it "traces the action", versioning: true do
              expect(Decidim::Plans.loggability)
                .to receive(:perform_action!)
                .with(:create, Decidim::Plans::Plan, kind_of(Decidim::User))
                .and_call_original

              expect { command.call }.to change(Decidim::ActionLog, :count)
              action_log = Decidim::ActionLog.last
              expect(action_log.version).to be_present
            end
          end

          describe "when the plan has a taxonomy section" do
            let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
            let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
            let(:taxonomy_filter) do
              create(
                :taxonomy_filter,
                root_taxonomy:,
                participatory_space_manifests: [component.participatory_space.manifest.name]
              )
            end
            let(:taxonomy_section) { create(:section, :field_taxonomy, component:) }

            let(:form_params) do
              {
                title: { en: "This is the plan title" },
                contents: [
                  {
                    section_id: taxonomy_section.id,
                    taxonomy_ids: [taxonomy.id.to_s]
                  }
                ]
              }
            end

            before do
              component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
              component.save!
            end

            it "saves the taxonomy_ids in the content body" do
              command.call
              plan = Decidim::Plans::Plan.last
              content = plan.contents.find_by(section: taxonomy_section)

              expect(content).to be_present
              expect(content.body["taxonomy_ids"]).to eq([taxonomy.id])
            end

            it "creates the taxonomization for the plan" do
              command.call
              plan = Decidim::Plans::Plan.last

              expect(plan.taxonomizations.count).to eq(1)
              expect(plan.taxonomizations.first.taxonomy_id).to eq(taxonomy.id)
            end

            it "saves the taxonomy_ids in the content body and creates the taxonomization" do
              command.call
              plan = Decidim::Plans::Plan.last
              content = plan.contents.find_by(section: taxonomy_section)

              expect(content).to be_present
              expect(content.body["taxonomy_ids"]).to eq([taxonomy.id])

              expect(plan.taxonomizations.count).to eq(1)
              expect(plan.taxonomizations.first.taxonomy_id).to eq(taxonomy.id)
            end

            context "when the taxonomy is later removed" do
              let(:form_params_with_blank) do
                {
                  title: { en: "This is the plan title" },
                  user_group_id: nil,
                  contents: [
                    {
                      section_id: taxonomy_section.id,
                      taxonomy_ids: [""]
                    }
                  ]
                }
              end

              it "does not create any taxonomization" do
                form_without_taxonomy = form_klass.from_params(form_params_with_blank).with_context(
                  current_user: user,
                  current_organization: organization,
                  current_participatory_space: component.participatory_space,
                  current_component: component
                )
                command_without_taxonomy = described_class.new(form_without_taxonomy)

                command_without_taxonomy.call
                plan = Decidim::Plans::Plan.last

                expect(plan.taxonomizations.count).to eq(0)
              end
            end
          end
        end
      end
    end
  end
end
