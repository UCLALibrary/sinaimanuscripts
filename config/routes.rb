# frozen_string_literal: true
Rails.application.routes.draw do
  concern :oai_provider, BlacklightOaiProvider::Routes.new

  mount Flipflop::Engine => "/flipflop"

  # Sinai static pages
  # get '/login', to: 'login#new', as: 'login'
  get '/about', to: 'static#about'
  get '/about/sinai-library-digitization-project', to: 'static#sinai_library_digitization_project', as: 'sinai_library_digitization_project'
  get '/about/syriac-parchment-description-project', to: 'static#syriac_parchment_description_project', as: 'syriac_parchment_description_project'
  get '/about/sinai-palimpsests-project', to: 'static#sinai_palimpsests_project', as: 'sinai_palimpsests_project'
  get '/contributors_credits', to: redirect('/about/sinai-library-digitization-project', status: 301)
  get '/contact', to: 'static#contact'
  get '/manuscript_descriptions', to: 'static#manuscript_descriptions'
  get '/terms-of-use', to: 'static#terms_of_use'
  get '/references', to: 'static#references'

  # Canon Law
  get '/canonlaw', to: 'canon_law#index'
  get '/canonlaw/introduction', to: 'canon_law#introduction'
  get '/canonlaw/table_of_contents', to: 'canon_law#table_of_contents'
  get '/canonlaw/margarita_decretalium', to: 'canon_law#margarita'
  get '/canonlaw/materiae_singulares', to: 'canon_law#materiae'

  get '/version', to: 'static#version'

  concern :range_searchable, BlacklightRangeLimit::Routes::RangeSearchable.new
  concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :oai_provider

    concerns :searchable
    concerns :range_searchable
  end

  devise_for :users
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  mount Blacklight::Engine => '/'
  mount BlacklightDynamicSitemap::Engine => '/'

  root to: "catalog#index"
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
