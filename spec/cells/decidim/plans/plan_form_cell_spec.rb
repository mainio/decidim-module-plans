# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanFormCell, type: :cell do
  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan_form", model, disable_user_group_field: true, context: { plan: }) }
  let(:model) { Decidim::FormBuilder.new(:plan, form, view, {}) }

  let(:template_class) do
    Class.new(ActionView::Base) do
      def compiled_method_container
        self.class
      end
    end
  end
  let(:view) { template_class.new(ActionView::LookupContext.new(ActionController::Base.view_paths), {}, controller) }
  let(:form) { Decidim::Plans::PlanForm.from_model(plan) }
  let(:plan) { create(:plan) }

  controller Decidim::Plans::PlansController

  include_context "with full plan form"

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
    allow(form).to receive(:current_component).and_return(plan.component)
    allow(view).to receive(:current_organization).and_return(plan.organization)
    allow(view).to receive(:snippets).and_return(controller.snippets)
    allow(controller).to receive(:current_organization).and_return(plan.organization)
    allow(controller).to receive(:current_component).and_return(plan.component)
    allow(controller).to receive(:current_participatory_space).and_return(plan.participatory_space)
  end

  context "when rendering" do
    it "renders the form" do
      sections.each do |section|
        expect(subject).to have_content(translated(section.body))

        case section.section_type
        when "field_attachments"
          within ".upload-container-for-attachments" do
            expect(subject).to have_button("#contents_#{section.id}_attachments_button", text: "Change attachment")
          end
        when "field_image_attachments"
          within ".upload-container-for-attachments" do
            expect(subject).to have_button("#contents_#{section.id}_attachments_button", text: "Change image")
          end
        when "link_proposals"
          expect(subject).to have_content("Choose proposals")
        end
      end
    end
  end
end
