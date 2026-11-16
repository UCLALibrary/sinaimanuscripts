# frozen_string_literal: true
require 'rails_helper'

# NOP-179: the "JSON Record" link on References & Bibliography. Solr ids are ARKs,
# whose slashes travel %2F-encoded inside the single :id segment (as on the show page).
RSpec.describe 'manuscript JSON route', type: :routing do
  it 'routes an ARK id with encoded slashes to CatalogController#manuscript_json' do
    expect(get: '/catalog/ark:%2F21198%2Ftest/manuscript_json')
      .to route_to(controller: 'catalog', action: 'manuscript_json', id: 'ark:/21198/test')
  end

  it 'builds the path with the ARK slashes encoded' do
    expect(manuscript_json_path('ark:/21198/test')).to eq('/catalog/ark:%2F21198%2Ftest/manuscript_json')
  end
end
