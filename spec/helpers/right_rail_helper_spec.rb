# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RightRailHelper, type: :helper do
  describe '#extract_nav_entries_from_html' do
    subject(:result) { helper.extract_nav_entries_from_html(html) }

    # Mirrors the Guest Content tab markup: an h2 section title (skipped), guest
    # layers as h3, items as h4, works as accordion titles, and an in-layer
    # paracontent block wrapped in data-nav-skip.
    let(:html) do
      <<~HTML
        <h2 data-nav-skip>Guest Content</h2>
        <details class="work-accordion--sinai">
          <summary><h3 class="work-accordion__title--sinai">Guest Layer 1</h3></summary>
          <h4>Item 1</h4>
          <details class="work-accordion--sinai">
            <summary><span class="work-accordion__title--sinai">Work A</span></summary>
          </details>
          <div data-nav-skip>
            <details class="work-accordion--sinai">
              <summary><span class="work-accordion__title--sinai">In-layer rubric</span></summary>
            </details>
          </div>
        </details>
        <details class="work-accordion--sinai">
          <summary><h3 class="work-accordion__title--sinai">Guest Paracontent 1</h3></summary>
        </details>
      HTML
    end

    let(:entries) { result.first }

    it 'omits nodes marked data-nav-skip and those inside a data-nav-skip ancestor' do
      labels = entries.flat_map { |e| [e[:label]] + e[:children].flat_map { |c| [c[:label]] + c[:children].map { |g| g[:label] } } }
      expect(labels).not_to include('Guest Content')      # data-nav-skip on the node
      expect(labels).not_to include('In-layer rubric')    # inside a data-nav-skip ancestor
    end

    it 'nests Guest Layer (h3) > Item (h4) > Work, with paracontent parallel to the layer' do
      expect(entries.map { |e| e[:label] }).to eq(['Guest Layer 1', 'Guest Paracontent 1'])

      layer = entries.first
      expect(layer[:children].map { |c| c[:label] }).to eq(['Item 1'])
      expect(layer[:children].first[:children].map { |c| c[:label] }).to eq(['Work A'])

      expect(entries.last[:children]).to be_empty
    end

    it 'returns no entries when every heading is skipped' do
      nav, = helper.extract_nav_entries_from_html('<h2 data-nav-skip>Only heading</h2>')
      expect(nav).to be_empty
    end
  end
end
