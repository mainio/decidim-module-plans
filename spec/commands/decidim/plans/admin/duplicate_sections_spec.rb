# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe DuplicateSections do
        let(:current_organization) { create(:organization, tos_version: Time.current) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:old_component) { create(:plan_component, participatory_space: participatory_process) }
        let(:new_component) { create(:plan_component, participatory_space: participatory_process) }
        let!(:sections) { create_list(:section, 3, component: old_component) }

        let(:ignored_attributes) { %w(id decidim_component_id created_at updated_at) }

        it "creates a copy of every section in the new component" do
          expect { described_class.call(old_component, new_component) }
            .to change { Decidim::Plans::Section.where(component: new_component).count }.from(0).to(3)
        end

        it "copies the attributes of each section" do
          described_class.call(old_component, new_component)

          original = Decidim::Plans::Section.where(component: old_component).order(:id)
          copies = Decidim::Plans::Section.where(component: new_component).order(:id)

          expect(copies.map { |section| section.attributes.except(*ignored_attributes) })
            .to eq(original.map { |section| section.attributes.except(*ignored_attributes) })
        end

        it "leaves the original sections untouched" do
          expect { described_class.call(old_component, new_component) }
            .not_to(change { Decidim::Plans::Section.where(component: old_component).pluck(:id) })
        end

        context "when the old component has no sections" do
          let!(:sections) { [] }

          it "does not create anything" do
            expect { described_class.call(old_component, new_component) }
              .not_to change(Decidim::Plans::Section, :count)
          end
        end
      end

      describe "PlansComponentDuplicateHook" do
        let(:old_component) { create(:plan_component) }
        let(:new_component) { create(:plan_component) }
        let!(:sections) { create_list(:section, 2, component: old_component) }

        it "duplicates the sections when hook runs" do
          expect do
            old_component.manifest.run_hooks(:duplicate, new_component:, old_component:)
          end.to change { Decidim::Plans::Section.where(component: new_component).count }.from(0).to(2)
        end
      end
    end
  end
end
