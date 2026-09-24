# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'Static pages', type: :request do
  describe 'GET /contributors_credits' do
    it 'permanently redirects to the Sinai Library Digitization Project page' do
      get '/contributors_credits'
      expect(response).to have_http_status(:moved_permanently)
      expect(response).to redirect_to('/about/sinai-library-digitization-project')
    end
  end
end
