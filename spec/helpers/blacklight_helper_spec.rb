# frozen_string_literal: true

require 'rails_helper'

RSpec.describe BlacklightHelper, type: :helper do
  before do
    allow(helper).to receive(:current_or_guest_user).and_return(User.new)
    @document = document
  end

  describe 'render_license' do
    context 'cc 4.0 license' do
      let(:document) do
        SolrDocument.new(
          'title_tsim' => "A Fake Document",
          'id' => '8',
          'license_tesim' => ["http://creativecommons.org/licenses/by/4.0/"]
        )
      end
      it 'renders a cc license' do
        expect(render_license).to match(/Creative Commons Attribution 4.0 International License/)
      end
    end
    context 'no license' do
      let(:document) do
        SolrDocument.new(
          'title_tsim' => "A Fake Document",
          'id' => '8'
        )
      end
      it 'does not render a licence' do
        expect(render_license).to be ''
      end
    end
    context 'a different value' do
      let(:document) do
        SolrDocument.new(
          'title_tsim' => "A Fake Document",
          'id' => '8',
          'license_tesim' => ["some other value"]
        )
      end
      it 'returns a default value' do
        expect(render_license).to eq "some other value"
      end
    end
  end

  describe 'render_opac_link' do
    xit do
    end
  end

  describe 'render_overtext_manuscript_links' do
    context 'has links in solr document' do
      let(:document) do
        SolrDocument.new(
          'title_tsim' => "A Fake Document",
          'id' => '8',
          'overtext_manuscript_ssm' => ["http://www.google.com", "http://www.bk.org"]
        )
      end
      it 'returns links' do
        expect(render_overtext_manuscript_links).to eq '<a href="http://www.google.com" target="_blank">http://www.google.com</a><br><a href="http://www.bk.org" target="_blank">http://www.bk.org</a><br>'
      end
      
    end
  end

  describe 'render_undertext_objects_markup' do
    context 'has html in solr document' do
      let(:document) do
        SolrDocument.new(
          'title_tsim' => "A Fake Document",
          'id' => '8',
          'undertext_objects_ssim' => ["<a href=“https://sinaimanuscripts.library.ucla.edu/catalog/ark:%2F21198%2Fz12r59fj”>Months of the Zodiac</a> (Arabic, 10th c. CE), Folios: 119v", "Divine Liturgy of Saint James (Greek, 9th c. CE), Folios: 50-52, 56, 63, 74-77, 96-106, 109-110 "]
        )
      end
      it 'returns html markup' do
        expect(render_undertext_objects_markup).to eq '<a href=“https://sinaimanuscripts.library.ucla.edu/catalog/ark:%2F21198%2Fz12r59fj”>Months of the Zodiac</a> (Arabic, 10th c. CE), Folios: 119v<br>Divine Liturgy of Saint James (Greek, 9th c. CE), Folios: 50-52, 56, 63, 74-77, 96-106, 109-110 <br>'
      end
      
    end
  end

  describe 'render_truncated_list' do
    context 'no field values' do
      let(:document) {}
      let(:field_values) do
        []
      end
      it 'no change' do
        expect(render_truncated_list(field_values)).to eq "<div class='metadata-value-index--sinai'></div>"
      end
    end
    context '3 or fewer fields' do
      let(:document) {}
      let(:field_values) do
        ["title1", "title2"]
      end
      it 'adds divider(s), no truncation' do
        expect(render_truncated_list(field_values)).to eq "<div class='metadata-value-index--sinai'>title1&nbsp;|&nbsp;title2</div>"
      end
    end
    context '4 or more filed values' do
      let(:document) {}
      let(:field_values) do
        ["title1", "title2", "title3", "title4"]
      end
      it 'adds dividers, truncates to 3, adds ellipises' do
        expect(render_truncated_list(field_values)).to eq "<div class='metadata-value-index--sinai'>title1&nbsp;|&nbsp;title2&nbsp;|&nbsp;title3&nbsp;|&nbsp;...</div>"
      end
    end
  end

  describe 'render_other_versions_link' do
    context 'renders other_versions' do
      let(:document) do
        SolrDocument.new(
          'other_versions_tesim' => ["https://www.test"]
        )
      end
      it 'displays a linked href value' do
        expect(render_other_versions_link).to eq '<a href="https://www.test "target="_blank">https://www.test</a> <br>'
      end
    end
  end
end
