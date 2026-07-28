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
end
