# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::UpdatePlan do
  let(:form_klass) { Decidim::Plans::Admin::PlanForm }

  let(:component) { create(:plan_component) }
  let(:organization) { component.organization }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:form) do
    form_klass.from_params(
      form_params
    ).with_context(
      current_organization: organization,
      current_participatory_space: component.participatory_space,
      current_user: user,
      current_component: component
    )
  end

  let!(:plan) { create(:plan, component:) }

  describe "call" do
    let(:form_params) do
      {}
    end

    let(:command) do
      described_class.new(form, plan)
    end

    describe "when the form is not valid" do
      before do
        allow(form).to receive(:invalid?).and_return(true)
      end

      it "broadcasts invalid" do
        expect { command.call }.to broadcast(:invalid)
      end

      it "doesn't update the plan" do
        expect(Decidim::Plans.loggability).not_to receive(:update!)

        command.call
      end
    end

    describe "when the form is valid" do
      it "broadcasts ok" do
        expect { command.call }.to broadcast(:ok)
      end

      it "updates the plan" do
        expect(Decidim::Plans.loggability).to receive(:update!)

        command.call
      end

      it "traces the update", versioning: true do
        expect(Decidim::Plans.loggability)
          .to receive(:update!)
          .with(plan, user, a_kind_of(Hash))
          .and_call_original

        expect { command.call }.to change(Decidim::ActionLog, :count)

        action_log = Decidim::ActionLog.last
        expect(action_log.version).to be_present
        expect(action_log.version.event).to eq "update"
      end

      it "does not update the plan authors" do
        expect do
          command.call
        end.not_to change(plan, :authors)
      end
    end

    describe "when the plan has a taxonomy section" do
      let(:root_taxonomy) { create(:taxonomy, organization:, skip_injection: true) }
      let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
      let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:, skip_injection: true) }
      let(:taxonomy_filter) do
        create(
          :taxonomy_filter,
          root_taxonomy:,
          participatory_space_manifests: [component.participatory_space.manifest.name]
        )
      end
      let(:taxonomy_section) { create(:section, :field_taxonomy, component:) }

      before do
        component.settings = component.settings.to_h.merge(taxonomy_filters: [taxonomy_filter.id])
        component.save!
      end

      context "when adding a taxonomy to a plan that had none" do
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

        it "saves the taxonomy_ids in the content body" do
          command.call
          content = plan.contents.find_by(section: taxonomy_section)

          expect(content).to be_present
          expect(content.body["taxonomy_ids"]).to eq([taxonomy.id])
        end

        it "creates the taxonomization for the plan" do
          command.call

          expect(plan.taxonomizations.count).to eq(1)
          expect(plan.taxonomizations.first.taxonomy_id).to eq(taxonomy.id)
        end
      end

      context "when the plan already has a taxonomy" do
        let!(:existing_content) do
          create(:content, :field_taxonomy, section: taxonomy_section, plan:, taxonomy:)
        end

        before do
          plan.taxonomizations.find_or_create_by(taxonomy_id: taxonomy.id)
        end

        context "and the taxonomy is changed to a different one" do
          let(:form_params) do
            {
              title: { en: "This is the plan title" },
              contents: [
                {
                  section_id: taxonomy_section.id,
                  id: existing_content.id,
                  taxonomy_ids: [other_taxonomy.id.to_s]
                }
              ]
            }
          end

          it "replaces the taxonomization" do
            command.call

            expect(plan.taxonomizations.count).to eq(1)
            expect(plan.taxonomizations.first.taxonomy_id).to eq(other_taxonomy.id)
          end
        end

        context "and the taxonomy is cleared (set to blank)" do
          let(:form_params) do
            {
              title: { en: "This is the plan title" },
              contents: [
                {
                  section_id: taxonomy_section.id,
                  id: existing_content.id,
                  taxonomy_ids: [""]
                }
              ]
            }
          end

          it "removes the existing taxonomization" do
            expect { command.call }.to change { plan.taxonomizations.count }.from(1).to(0)
          end

          it "clears the taxonomy_ids from the content body" do
            command.call
            content = plan.contents.find_by(section: taxonomy_section)

            expect(content.body["taxonomy_ids"]).to eq([])
          end
        end
      end
    end
  end
end
