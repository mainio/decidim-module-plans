# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::PlanViewCell, type: :cell do
  include ActionView::Helpers::NumberHelper

  subject { my_cell.call }

  let(:my_cell) { cell("decidim/plans/plan_view", model, context: { current_component: model.component }) }
  let(:model) { create(:plan) }

  controller Decidim::Plans::PlansController

  include_context "with full plan form" do
    let(:plan) { model }
  end

  before do
    allow(my_cell).to receive(:controller).and_return(controller)
    allow(controller).to receive(:current_organization).and_return(model.organization)
    allow(controller).to receive(:current_component).and_return(model.component)
    allow(controller).to receive(:current_participatory_space).and_return(model.participatory_space)
  end

  context "when rendering" do
    it "renders the form" do
      contents = subject.find(".plan-contents")

      sections.each do |section|
        content = model.contents.find_by(section:)
        case section.section_type
        when "field_area_scope", "field_scope"
          expect_scope(section, content, contents)
        when "field_attachments"
          expect_attachments(section, content, contents)
        when "field_category"
          expect_category(section, content, contents)
        when "field_checkbox"
          expect_checkbox(section, content, contents)
        when "field_currency"
          expect_currency(section, content, contents)
        when "field_map_point"
          expect_map_point(section, content, contents)
        when "field_number"
          expect_number(section, content, contents)
        when "field_tags"
          expect_tags(section, content, contents)
        when "link_proposals"
          expect_proposals(section, content, contents)
        when "field_title"
          expect(subject).to have_css("h2", text: translated(model.title))
        when "field_text", "field_text_multiline"
          expect_text(section, content, contents)
        end
      end
    end

    def expect_text(section, content, node)
      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(translated(content.body))
    end

    def expect_scope(section, content, node)
      scope = Decidim::Scope.find(content.body["scope_id"])

      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(translated(scope.name))
    end

    def expect_category(section, content, node)
      category = Decidim::Category.find(content.body["category_id"])

      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(category.name["es"])
    end

    def expect_checkbox(section, content, node)
      expect(node).to have_content(translated(section.body))
      if content.body["value"]
        expect(node).to have_content("Yes")
      else
        expect(node).to have_content("No")
      end
    end

    def expect_number(section, content, node)
      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(number_with_delimiter(content.body["value"], locale: I18n.locale))
    end

    def expect_currency(section, content, node)
      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(number_to_currency(content.body["value"], unit: Decidim.currency_unit, precision: 0, locale: I18n.locale))
    end

    def expect_map_point(section, content, node)
      expect(node).to have_content(translated(section.body))
      expect(node).to have_content(content.body["address"])
    end

    def expect_tags(section, content, node)
      expect(node).to have_content(translated(section.body))
      content.body["tag_ids"].each do |tag_id|
        tag = Decidim::Tags::Tag.find(tag_id)
        expect(node).to have_content(translated(tag.name))
      end
    end

    def expect_attachments(_section, content, node)
      expect(node).to have_content("Related documents")
      expect(node).to have_content("Related photos")
      content.body["attachment_ids"].each do |attachment_id|
        attachment = Decidim::Attachment.find(attachment_id)
        if attachment.photo?
          expect(node).to have_css("img[alt='#{translated(attachment.title)}']")
        else
          expect(node).to have_content(translated(attachment.title))
        end
      end
    end

    def expect_image_attachments(_section, content, node)
      expect(node).to have_content("Related photos")
      content.body["attachment_ids"].each do |attachment_id|
        attachment = Decidim::Attachment.find(attachment_id)
        expect(node).to have_css(%(img[alt="#{translated(attachment.title)}"]))
      end
    end

    def expect_proposals(section, content, node)
      expect(node).to have_css(".attached-proposals")

      proposals = node.find(".attached-proposals")
      expect(proposals).to have_content(translated(section.body))

      content.body["proposal_ids"].each do |proposal_id|
        proposal = Decidim::Proposals::Proposal.find(proposal_id)
        expect(proposals).to have_content(translated(proposal.title))
      end
    end
  end
end
