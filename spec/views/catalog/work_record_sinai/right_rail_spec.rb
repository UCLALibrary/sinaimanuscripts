# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'catalog/work_record--sinai/_right_rail.html.erb', type: :view do
  let(:document) { SolrDocument.new(id: 'test-rail-01', shelfmark_ssi: 'Test Rail 01') }

  # show_examine: false keeps the partial from reaching for cookies/manifest;
  # this spec is about the Expand-all control (NOP-177), not the viewer card.
  def render_rail(locals = {})
    render partial: 'catalog/work_record--sinai/right_rail',
           locals: { document: document, entries: nil, show_examine: false }.merge(locals)
  end

  describe 'Expand all / Collapse all control' do
    it 'renders the toggle when the tab has collapsible content' do
      render_rail(show_expand_all: true)

      expect(rendered).to have_css('button.right-rail__expand-btn--sinai[data-expand-all-toggle]')
      expect(rendered).to have_css("button.right-rail__expand-btn--sinai[data-state='collapsed']")
      expect(rendered).to have_css('.right-rail__expand-label--sinai', text: 'Expand all')
    end

    # The core NOP-177 requirement: the control is driven by collapsible content,
    # not by whether the tab has a Navigation or Examine card.
    it 'renders standalone, with no Navigation card and no Examine card' do
      render_rail(show_expand_all: true)

      expect(rendered).to have_css('[data-expand-all-toggle]')
      expect(rendered).not_to have_css('.right-rail__nav-card--sinai')
      expect(rendered).not_to have_css('.right-rail__viewer-card--sinai')
    end

    it 'omits the toggle when the tab has nothing to expand' do
      render_rail(show_expand_all: false)

      expect(rendered).not_to have_css('[data-expand-all-toggle]')
    end

    it 'defaults to omitting the toggle so other callers are unaffected' do
      render_rail

      expect(rendered).not_to have_css('[data-expand-all-toggle]')
    end

    # Locks in the "first in the sticky column" decision: .right-rail__sticky--sinai
    # is a max-height scroller, so a long nav tree must not push the control below
    # the internal fold.
    it 'places the toggle above the Navigation card' do
      render_rail(show_expand_all: true,
                  entries: [{ id: 'section-overview', label: 'Overview', children: [] }])

      expect(rendered).to have_css('.right-rail__nav-card--sinai')
      expect(rendered.index('right-rail__expand-card--sinai'))
        .to be < rendered.index('right-rail__nav-card--sinai')
    end
  end

  # NOP-182. The nav tree is one recursive partial shared by Full Description,
  # Contents and Guest Content; works land at level 3 (depth 2) on all three, so
  # the truncation is keyed on depth rather than on which helper built the tree.
  describe 'work list truncation' do
    # Part > Item 1 > N works: the shape every tab's tree converges on.
    def tree_with_works(count)
      works = (1..count).map do |n|
        { id: "section-part-0-item-1-work-#{n}", label: "Work #{n}", children: [] }
      end
      [{ id: 'section-part-0', label: 'Part 1', children: [
        { id: 'section-part-0-item-1', label: 'Item 1', children: works }
      ] }]
    end

    # visible: :all throughout, because the tree renders inside a <details> that omits
    # `open` (collapsed by default on mobile, forced open by CSS on desktop), so
    # Capybara's default visibility filter would report every row as hidden and
    # make the negative assertions pass for the wrong reason.
    def expect_rail_css(selector, **options)
      expect(rendered).to have_css(selector, visible: :all, **options)
    end

    def expect_no_rail_css(selector)
      expect(rendered).not_to have_css(selector, visible: :all)
    end

    it 'shows four of five works behind a Show More toggle' do
      render_rail(entries: tree_with_works(5))

      # All five still ship: scroll-spy tracks every link, and right_rail_nav.js
      # reveals the group when a hidden one becomes current.
      expect_rail_css('.right-rail__nav-link--lvl-3--sinai', count: 5)
      expect_rail_css('.right-rail__nav-item--hidden--sinai', count: 1)
      expect_rail_css('ul.right-rail__nav-list--more--sinai[data-rail-nav-more-group]', count: 1)
      expect_rail_css('button.right-rail__nav-more--sinai', text: 'Show More', count: 1)
    end

    it 'leaves four works untruncated' do
      render_rail(entries: tree_with_works(4))

      expect_rail_css('.right-rail__nav-link--lvl-3--sinai', count: 4)
      expect_no_rail_css('.right-rail__nav-item--hidden--sinai')
      expect_no_rail_css('[data-rail-nav-more-group]')
      expect_no_rail_css('.right-rail__nav-more--sinai')
    end

    # Guards the depth rule: a record with five parts must not collapse its
    # top-level sections, only the work lists nested under an Item.
    it 'never truncates the top-level section list' do
      entries = (1..5).map { |n| { id: "section-part-#{n}", label: "Part #{n}", children: [] } }
      render_rail(entries: entries)

      expect_rail_css('.right-rail__nav-link--lvl-1--sinai', count: 5)
      expect_no_rail_css('.right-rail__nav-item--hidden--sinai')
      expect_no_rail_css('.right-rail__nav-more--sinai')
    end

    # Items are level 2; the ticket truncates works only.
    it 'never truncates the item list under a part' do
      items = (1..5).map do |n|
        { id: "section-part-0-item-#{n}", label: "Item #{n}", children: [] }
      end
      render_rail(entries: [{ id: 'section-part-0', label: 'Part 1', children: items }])

      expect_rail_css('.right-rail__nav-link--lvl-2--sinai', count: 5)
      expect_no_rail_css('.right-rail__nav-more--sinai')
    end
  end
end
