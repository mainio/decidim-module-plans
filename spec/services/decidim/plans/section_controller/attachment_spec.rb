# frozen_string_literal: true

require "spec_helper"

module Decidim
  module Plans
    module SectionControl
      describe Attachments do
        subject { described_class.new(form) }
        let(:form) { Decidim::Plans::ContentData::FieldAttachmentsForm.from_params(add_attachments: images, content_id: content.id, section_id: section.id) }
        let(:section) { create(:section, :field_image_attachments, component: plan.component) }
        let(:component) { create(:plan_component) }
        let(:organization) { component.organization }
        let(:author) { create(:user, :confirmed, organization:) }
        let(:plan) { create(:plan, component:) }
        let(:content) { create(:content, :field_attachments, plan:, images:, user:) }
        let(:documents) { create_list(:attachment, 3, :with_pdf, attached_to: plan) }
        let(:images) { create_list(:attachment, 3, :with_image, attached_to: plan) }
        let!(:user) { create(:user, :confirmed, organization:) }

        describe "prepare!" do
          it "returns true with total weight" do
            expect(subject.prepare!(plan)).to be true
            expect(subject.total_weight).to eq(0)
          end
        end

        describe "save!" do
          context "with attachements are saved!" do
            before do
              allow(form).to receive(:current_user).and_return(user)
              subject.prepare!(plan)
            end

            it "saves the attachements and return them" do
              subject.save!(plan)
              expect(subject.total_weight).to eq(3)
            end
          end
        end
      end
    end
  end
end
