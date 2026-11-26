# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe PlanTransferForm do
        subject(:form) do
          described_class.from_params(transfer: params).with_context(
            current_organization: organization,
            current_component: source
          )
        end

        let(:organization) { create(:organization) }
        let(:space) { create(:participatory_process, :published, organization:) }
        let(:source) { create(:plan_component, participatory_space: space) }
        let(:target) { create(:plan_component, participatory_space: space) }
        let!(:source_sections) { create_list(:section, 2, component: source, section_type: "field_text") }
        let!(:target_sections) { create_list(:section, 2, component: target, section_type: "field_text") }
        let(:mapping) do
          {
            source_sections[0].id.to_s => target_sections[0].id.to_s,
            source_sections[1].id.to_s => target_sections[1].id.to_s
          }
        end

        let(:params) { { target_component_id: target.id, section_mapping: mapping } }

        it { is_expected.to be_valid }

        describe "#mapping" do
          it "converts the keys and values to integers" do
            expect(form.mapping).to eq(
              source_sections[0].id => target_sections[0].id,
              source_sections[1].id => target_sections[1].id
            )
          end
        end

        context "when the target has a different number of sections" do
          let!(:extra_section) { create(:section, component: target, section_type: "field_text") }

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:target_component_id]).to be_present
          end
        end

        context "when two sections are mapped to the same target section" do
          let(:mapping) do
            {
              source_sections[0].id.to_s => target_sections[0].id.to_s,
              source_sections[1].id.to_s => target_sections[0].id.to_s
            }
          end

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:section_mapping]).to be_present
          end
        end

        context "when a source section is not mapped" do
          let(:mapping) { { source_sections[0].id.to_s => target_sections[0].id.to_s } }

          it "is invalid" do
            expect(form).not_to be_valid
          end
        end

        context "when the paired sections have different types" do
          let!(:target_sections) do
            [
              create(:section, component: target, section_type: "field_text"),
              create(:section, component: target, section_type: "field_number")
            ]
          end

          it "is invalid" do
            expect(form).not_to be_valid
            expect(form.errors[:section_mapping]).to be_present
          end
        end

        context "when the target component does not exist" do
          let(:params) { { target_component_id: 0, section_mapping: mapping } }

          it "is invalid" do
            expect(form).not_to be_valid
          end
        end

        describe "#same_space?" do
          it { expect(form.same_space?).to be(true) }

          context "when the target is in another space" do
            let(:other_space) { create(:participatory_process, :published, organization:) }
            let(:target) { create(:plan_component, participatory_space: other_space) }

            it { expect(form.same_space?).to be(false) }
          end
        end

        describe "taxonomy mapping" do
          let(:other_space) { create(:participatory_process, :published, organization:) }
          let(:target) { create(:plan_component, participatory_space: other_space) }
          let(:root_taxonomy) { create(:taxonomy, organization:) }
          let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
          let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
          let(:plan) { create(:plan, component: source) }

          before do
            plan.taxonomies = [taxonomy]
            allow(form).to receive(:target_taxonomy_ids).and_return(target_ids)
          end

          context "when the target space has taxonomies" do
            let(:target_ids) { [other_taxonomy.id] }

            it "needs mapping" do
              expect(form.taxonomy_mapping_needed?).to be(true)
            end

            context "with a mapping to an allowed taxonomy" do
              let(:params) { super().merge(taxonomy_mapping: { taxonomy.id.to_s => other_taxonomy.id.to_s }) }

              it { is_expected.to be_valid }
            end

            context "with a mapping to a taxonomy the target does not allow" do
              let(:params) { super().merge(taxonomy_mapping: { taxonomy.id.to_s => taxonomy.id.to_s }) }

              it { is_expected.not_to be_valid }
            end

            context "with a blank target" do
              let(:params) { super().merge(taxonomy_mapping: { taxonomy.id.to_s => "" }) }

              it { is_expected.to be_valid }
            end
          end

          context "when the target space has no taxonomies" do
            let(:target_ids) { [] }

            it "needs no mapping" do
              expect(form.taxonomy_mapping_needed?).to be(false)
            end
          end
        end
      end
    end
  end
end
