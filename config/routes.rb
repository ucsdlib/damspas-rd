Rails.application.routes.draw do
  
  require 'sidekiq/web'
  mount Sidekiq::Web => '/sidekiq'

  mount BrowseEverything::Engine => '/browse'
  mount Blacklight::Engine => '/'
  mount BlacklightAdvancedSearch::Engine => '/'

  
    concern :searchable, Blacklight::Routes::Searchable.new

  resource :catalog, only: [:index], as: 'catalog', path: '/catalog', controller: 'catalog' do
    concerns :searchable
  end

  devise_for :users
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  curation_concerns_embargo_management
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :csv_imports, only: [:new, :create], controller: 'csv_imports'

  resources :pages
  get '/p/:id', to: 'pages#view', :as => 'view_page'

  get 'dams_authorities/:authority/:id', to: 'dams_authorities#show', as: 'authority', :constraints => { authority: /(agent|concept|place)/ }
  resources :records

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end