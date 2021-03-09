# frozen_string_literal: true
# gem 'rspec-collection_matchers'

require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  describe 'the static pages are successfully served' do
    context 'GET #sinai_terms_of_use' do
      it "returns http success" do
        get :sinai_terms_of_use
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:sinai_terms_of_use)
      end
    end

    context 'GET #sinai_contact' do
      it "returns http success" do
        get :sinai_contact
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:sinai_contact)
      end
    end

    context 'GET #sinai_about' do
      it "returns http success" do
        get :sinai_about
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:sinai_about)
      end
    end

    context 'GET #sinai_manuscript_descriptions' do
      it "returns http success" do
        get :sinai_manuscript_descriptions
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:sinai_manuscript_descriptions)
      end
    end
  end
end
