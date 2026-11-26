# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::Admin::TransferComponent do
  subject(:command) { described_class.new(form, source, user) }

  let(:organization) { create(:organization) }
  let(:user) { create(:user, :admin, :confirmed, organization:) }
  let(:space) { create(:participatory_process, :published, organization:) }
  let(:source) { create(:plan_component, participatory_space: space) }
  let(:target) { create(:plan_component, participatory_space: space) }
  let!(:source_section) { create(:section, component: source, section_type: "field_text") }
  let!(:target_section) { create(:section, component: target, section_type: "field_text") }
  let!(:plan) { create(:plan, component: source) }
  let!(:content) do
    Decidim::Plans::Content.create!(plan:, section: source_section, user:, body: { "en" => "Answer" })
  end

  let(:same_space) { true }
  let(:target_taxonomies) { Decidim::Taxonomy.none }
  let(:taxonomy_map) { {} }
  let(:form) do
    instance_double(
      Decidim::Plans::Admin::PlanTransferForm,
      invalid?: false,
      target_component: target,
      mapping: { source_section.id => target_section.id },
      same_space?: same_space,
      target_taxonomies:,
      taxonomy_map:
    )
  end

  it "broadcasts ok" do
    expect { command.call }.to broadcast(:ok)
  end

  it "moves the plans to the target component" do
    command.call

    expect(plan.reload.decidim_component_id).to eq(target.id)
    expect(Decidim::Plans::Plan.where(component: source)).to be_empty
  end

  it "re-points the contents to the mapped section" do
    command.call

    expect(content.reload.decidim_section_id).to eq(target_section.id)
    expect(content.body).to eq("en" => "Answer")
  end

  it "leaves the sections as they are" do
    expect { command.call }.not_to(change { Decidim::Plans::Section.pluck(:id, :decidim_component_id).sort })
  end

  it "copies the component settings to the target" do
    source.update!(settings: { multilingual_answers: true })

    command.call

    expect(target.reload.settings.multilingual_answers).to be(true)
  end

  context "when a content belongs to a section that is not mapped" do
    let!(:unmapped_section) { create(:section, component: source, section_type: "field_text") }
    let!(:unmapped_content) do
      Decidim::Plans::Content.create!(plan:, section: unmapped_section, user:, body: { "en" => "Stray" })
    end

    it "removes the content" do
      command.call

      expect(Decidim::Plans::Content.exists?(unmapped_content.id)).to be(false)
    end
  end

  describe "taxonomies" do
    let(:root_taxonomy) { create(:taxonomy, organization:) }
    let(:taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }
    let(:other_taxonomy) { create(:taxonomy, parent: root_taxonomy, organization:) }

    before { plan.taxonomies = [taxonomy] }

    context "when the space stays the same" do
      it "keeps the taxonomies" do
        command.call

        expect(plan.reload.taxonomies).to contain_exactly(taxonomy)
      end
    end

    context "when the space changes and the target has taxonomies" do
      let(:same_space) { false }
      let(:target_taxonomies) { Decidim::Taxonomy.where(id: other_taxonomy.id) }

      context "with a mapping" do
        let(:taxonomy_map) { { taxonomy.id => other_taxonomy.id } }

        it "applies the mapped taxonomy" do
          command.call

          expect(plan.reload.taxonomies).to contain_exactly(other_taxonomy)
        end
      end

      context "without a mapping for the taxonomy" do
        it "removes the taxonomy" do
          command.call

          expect(plan.reload.taxonomies).to be_empty
        end
      end

      context "when the space changes and the target has no taxonomies" do
        let(:same_space) { false }

        it "removes all taxonomies" do
          command.call

          expect(plan.reload.taxonomies).to be_empty
        end
      end
    end

    context "when the form is invalid" do
      let(:form) { instance_double(Decidim::Plans::Admin::PlanTransferForm, invalid?: true) }

      it "broadcasts invalid and changes nothing" do
        expect { command.call }.to broadcast(:invalid)

        expect(plan.reload.decidim_component_id).to eq(source.id)
        expect(content.reload.decidim_section_id).to eq(source_section.id)
      end
    end

    context "when copying the settings fails" do
      before do
        allow(target).to receive(:update!).and_raise(ActiveRecord::RecordInvalid.new(target))
      end

      it "rolls back the moved plans and contents" do
        expect { command.call }.to raise_error(ActiveRecord::RecordInvalid)

        expect(plan.reload.decidim_component_id).to eq(source.id)
        expect(content.reload.decidim_section_id).to eq(source_section.id)
      end
    end
  end
end
