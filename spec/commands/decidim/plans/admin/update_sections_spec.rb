# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module Admin
      describe UpdateSections do
        let(:current_organization) { create(:organization) }
        let(:participatory_process) { create(:participatory_process, organization: current_organization) }
        let(:sections_component) { create(:dummy_component) }
        let(:sections) { Section.where(component: sections_component) }
        let(:form_params) do
          {
            "sections" => {
              "0" => {
                "body" => { "en" => "First section" },
                "section_type" => Decidim::Plans::Section::TYPES.first,
                "position" => "0"
              },
              "1" => {
                "body" => { "en" => "Second section" },
                "section_type" => Decidim::Plans::Section::TYPES.second,
                "position" => "1"
              },
              "2" => {
                "body" => { "en" => "Third section" },
                "section_type" => Decidim::Plans::Section::TYPES.first,
                "position" => "2"
              },
              "3" => {
                "body" => { "en" => "Fourth section" },
                "section_type" => Decidim::Plans::Section::TYPES.second,
                "position" => "3"
              }
            }
          }
        end
        let(:form) do
          PlanSectionsForm.from_params(
            form_params
          ).with_context(
            current_organization: current_organization
          )
        end
        let(:command) { described_class.new(form, sections) }

        describe "when the form is invalid" do
          before do
            expect(form).to receive(:invalid?).and_return(true)
          end

          it "broadcasts invalid" do
            expect { command.call }.to broadcast(:invalid)
          end

          it "doesn't update sections" do
            expect(sections).not_to receive(:update!)
            command.call
          end
        end

        describe "when the form is valid" do
          it "broadcasts ok" do
            expect { command.call }.to broadcast(:ok)
          end

          it "updates sections" do
            command.call
            sections.reload

            expect(sections.length).to eq(4)

            sections.each_with_index do |section, idx|
              expect(section.body["en"]).to eq(form_params["sections"][idx.to_s]["body"]["en"])
              expect(section.position).to eq(form_params["sections"][idx.to_s]["position"].to_i)
            end
          end
        end

        describe "when a section exists" do
          let!(:section) { create(:section) }

          context "and it should be deleted" do
            let(:form_params) do
              {
                "sections" => [
                  {
                    "id" => section.id,
                    "body" => section.body,
                    "position" => 0,
                    "deleted" => "true"
                  }
                ]
              }
            end

            it "gets deleted" do
              command.call
              sections.reload

              expect(sections.length).to eq(0)
            end
          end
        end
      end
    end
  end
end
