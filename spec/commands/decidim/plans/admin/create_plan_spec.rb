# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe CreatePlan do
        let(:form_klass) { PlanForm }
        let(:component) { create(:plan_component) }
        let(:proposal_component) { create(:proposal_component, participatory_space: component.participatory_space) }
        let(:organization) { component.organization }
        let(:user) { create :user, :admin, :confirmed, organization: organization }
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
          let(:proposals) { create_list(:proposal, 3, component: proposal_component) }

          let(:form_params) do
            {
              title: { en: "A reasonable plan title" },
              attachments: attachment_params.nil? ? nil : [attachment_params],
              user_group_id: nil,
              proposal_ids: [proposals.map(&:id)]
            }
          end

          let(:command) do
            described_class.new(form)
          end

          describe "when the form is not valid" do
            before do
              expect(form).to receive(:invalid?).twice.and_return(true)
            end

            it "broadcasts invalid" do
              expect { command.call }.to broadcast(:invalid)
            end

            it "doesn't create a plan" do
              expect do
                command.call
              end.not_to change(Decidim::Plans::Plan, :count)
            end

            describe "with an attachment" do
              let(:component) { create(:plan_component, :with_attachments_allowed) }
              let(:attachment_params) do
                {
                  title: "My attachment",
                  file: Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                  weight: 0
                }
              end

              it "adds an error to the attachment's `:file` field" do
                command.call
                expect(form.attachments.first.errors.keys).to match_array([:file])
              end
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

            it "links proposals" do
              command.call
              plan = Decidim::Plans::Plan.last

              linked_proposals = plan.linked_resources(:proposals, "included_proposals")
              expect(linked_proposals).to match_array(proposals)
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

            context "when attachments are allowed", processing_uploads_for: Decidim::AttachmentUploader do
              let(:component) { create(:plan_component, :with_attachments_allowed) }
              let(:attachment_params) do
                {
                  title: "My attachment",
                  file: Decidim::Dev.test_file("city.jpeg", "image/jpeg"),
                  weight: 0
                }
              end

              it "creates an atachment for the plan" do
                expect { command.call }.to change(Decidim::Attachment, :count).by(1)
                last_plan = Decidim::Plans::Plan.last
                last_attachment = Decidim::Attachment.last
                expect(last_attachment.attached_to).to eq(last_plan)
              end

              context "when attachment is left blank" do
                let(:attachment_params) do
                  {
                    title: "",
                    weight: 0
                  }
                end

                it "broadcasts ok" do
                  expect { command.call }.to broadcast(:ok)
                end
              end
            end
          end
        end
      end
    end
  end
end
