# frozen_string_literal: true

require "spec_helper"

describe Decidim::Plans::AttachedProposalsHelper do
  let(:form) { double }
  let(:participatory_space) { create(:participatory_process, :with_steps) }
  let(:current_component) { create(:plan_component, participatory_space: participatory_space) }
  let(:proposal_component) { create(:proposal_component, participatory_space: participatory_space) }
  let(:search_proposals_path) { "/search_proposals" }

  before do
    allow(helper).to receive(:current_component).and_return(current_component)
    allow(helper).to receive(:plan_search_proposals_path).and_return(search_proposals_path)
  end

  describe "#attached_proposals_picker_field" do
    it "calls the form helper's data_picker method" do
      name = "pick_proposals"

      expect(form).to receive(:data_picker).with(
        name,
        {
          id: "attached_proposals",
          "class": "picker-multiple",
          name: "proposal_ids",
          multiple: true
        },
        url: search_proposals_path,
        text: "Attach proposal"
      )
      helper.attached_proposals_picker_field(form, name)
    end
  end

  describe "#search_proposals" do
    let(:format) { double }

    context "with no proposals available" do
      it "returns the proposals" do
        expect(format).to receive(:html).and_yield
        expect(format).to receive(:json).and_yield
        expect(helper).to receive(:respond_to).and_yield(format)

        # html
        expect(helper).to receive(:render).with(
          hash_including(
            partial: "decidim/plans/attached_proposals/proposals"
          )
        )
        # json
        expect(helper).to receive(:render).with(
          hash_including(
            json: []
          )
        )

        helper.search_proposals
      end
    end

    context "with accepted, evaluating and unpublished proposals" do
      let(:amount) { 10 }

      before do
        create_list(
          :proposal,
          amount,
          :accepted,
          published_at: Time.current,
          component: proposal_component
        )
        create_list(
          :proposal,
          amount,
          :evaluating,
          published_at: Time.current,
          component: proposal_component
        )
        create_list(
          :proposal,
          amount,
          :unpublished,
          component: proposal_component
        )
      end

      it "returns the proposals" do
        expect(format).to receive(:html).and_yield
        expect(format).to receive(:json).and_yield
        expect(helper).to receive(:respond_to).and_yield(format)

        # html
        expect(helper).to receive(:render).with(
          hash_including(
            partial: "decidim/plans/attached_proposals/proposals"
          )
        )
        # json
        proposals = Decidim::Proposals::Proposal.where(
          component: proposal_component
        ).where.not(
          published_at: nil
        ).order(title: :asc).all.collect { |p| ["#{p.title} (##{p.id})", p.id] }
        expect(helper).to receive(:render).with(
          hash_including(
            json: proposals
          )
        )

        helper.search_proposals
      end
    end

    context "with unanswered, accepted and rejected proposals" do
      let(:amount) { 10 }

      before do
        create_list(
          :proposal,
          amount,
          :published,
          component: proposal_component
        )
        create_list(
          :proposal,
          amount,
          :accepted,
          published_at: Time.current,
          component: proposal_component
        )
        create_list(
          :proposal,
          amount,
          :rejected,
          published_at: Time.current,
          component: proposal_component
        )
      end

      it "returns the proposals" do
        expect(format).to receive(:html).and_yield
        expect(format).to receive(:json).and_yield
        expect(helper).to receive(:respond_to).and_yield(format)

        # html
        expect(helper).to receive(:render).with(
          hash_including(
            partial: "decidim/plans/attached_proposals/proposals"
          )
        )
        # json
        proposals = Decidim::Proposals::Proposal.where(
          component: proposal_component
        ).where.not(
          published_at: nil
        ).where(
          "state IS NULL OR state != ?",
          "rejected"
        ).order(title: :asc).all.collect { |p| ["#{p.title} (##{p.id})", p.id] }
        expect(helper).to receive(:render).with(
          hash_including(
            json: proposals
          )
        )

        helper.search_proposals
      end
    end

    context "when searching with title" do
      let(:title) { "Search this title" }

      let!(:proposal) do
        create(
          :proposal,
          :published,
          component: proposal_component,
          title: title
        )
      end

      context "with matching term" do
        it "returns the proposals" do
          expect(format).to receive(:html).and_yield
          expect(format).to receive(:json).and_yield
          expect(helper).to receive(:respond_to).and_yield(format)
          allow(helper).to receive(:params).and_return(
            term: "this"
          )

          # html
          expect(helper).to receive(:render).with(
            hash_including(
              partial: "decidim/plans/attached_proposals/proposals"
            )
          )
          # json
          expect(helper).to receive(:render).with(
            hash_including(
              json: [["#{proposal.title} (##{proposal.id})", proposal.id]]
            )
          )

          helper.search_proposals
        end
      end

      context "with unmatching term" do
        it "returns the proposals" do
          expect(format).to receive(:html).and_yield
          expect(format).to receive(:json).and_yield
          expect(helper).to receive(:respond_to).and_yield(format)
          allow(helper).to receive(:params).and_return(
            term: "blablabla"
          )

          # html
          expect(helper).to receive(:render).with(
            hash_including(
              partial: "decidim/plans/attached_proposals/proposals"
            )
          )
          # json
          expect(helper).to receive(:render).with(
            hash_including(
              json: []
            )
          )

          helper.search_proposals
        end
      end
    end

    context "when searching with ID" do
      let!(:proposal) do
        create(
          :proposal,
          :published,
          component: proposal_component
        )
      end

      context "with matching ID" do
        it "returns the proposals" do
          expect(format).to receive(:html).and_yield
          expect(format).to receive(:json).and_yield
          expect(helper).to receive(:respond_to).and_yield(format)
          allow(helper).to receive(:params).and_return(
            term: "##{proposal.id}"
          )

          # html
          expect(helper).to receive(:render).with(
            hash_including(
              partial: "decidim/plans/attached_proposals/proposals"
            )
          )
          # json
          expect(helper).to receive(:render).with(
            hash_including(
              json: [["#{proposal.title} (##{proposal.id})", proposal.id]]
            )
          )

          helper.search_proposals
        end
      end

      context "with unmatching ID" do
        it "returns the proposals" do
          expect(format).to receive(:html).and_yield
          expect(format).to receive(:json).and_yield
          expect(helper).to receive(:respond_to).and_yield(format)
          allow(helper).to receive(:params).and_return(
            term: "#9#{proposal.id}9"
          )

          # html
          expect(helper).to receive(:render).with(
            hash_including(
              partial: "decidim/plans/attached_proposals/proposals"
            )
          )
          # json
          expect(helper).to receive(:render).with(
            hash_including(
              json: []
            )
          )

          helper.search_proposals
        end
      end
    end
  end
end
