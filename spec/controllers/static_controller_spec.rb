# frozen_string_literal: true
# gem 'rspec-collection_matchers'

require 'rails_helper'

RSpec.describe StaticController, type: :controller do
  describe 'the static pages are successfully served' do
    context 'GET #terms_of_use' do
      it "returns http success" do
        get :terms_of_use
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:terms_of_use)
      end
    end

    context 'GET #contact' do
      it "returns http success" do
        get :contact
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:contact)
      end
    end

    context 'GET #contributors_credits' do
      it "returns http success" do
        get :contributors_credits
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:contributors_credits)
      end
    end

    context 'GET #about' do
      it "returns http success" do
        get :about
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:about)
      end
    end

    context 'GET #manuscript_descriptions' do
      it "returns http success" do
        get :manuscript_descriptions
        expect(response).to have_http_status(:success)
        expect(response).to render_template(:manuscript_descriptions)
      end
    end
  end
end
