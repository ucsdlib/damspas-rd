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

  get '/batch_uploads/new', to: redirect('/batch_import/new')

  devise_for :users, controllers: { :omniauth_callbacks => "users/omniauth_callbacks" }

  devise_scope :user do
    get '/users/sign_in', :to => "users/sessions#new", :as => :new_user_session
    get '/users/sign_out', :to => "users/sessions#destroy", :as => :destroy_user_session
  end
  
  mount Hydra::RoleManagement::Engine => '/'
  mount Qa::Engine => '/authorities'
  mount Hyrax::Engine, at: '/'
  resources :welcome, only: 'index'
  root 'hyrax/homepage#index'
  curation_concerns_basic_routes
  concern :exportable, Blacklight::Routes::Exportable.new

  resources :solr_documents, only: [:show], path: '/catalog', controller: 'catalog' do
    concerns :exportable
  end

  resources :batch_import, only: [:new, :create], controller: 'batch_import'


  get 'dams_authorities/:authority/:id', to: 'dams_authorities#show', as: 'authority', :constraints => { authority: /(ucsd_agent|concept|place)/ }
  resources :records

  resources :bookmarks do
    concerns :exportable

    collection do
      delete 'clear'
    end
  end

  get 'faq' => 'hyrax/pages#show', key: 'faq'
  get 'takedown' => 'hyrax/pages#show', key: 'takedown'
  get 'search-tips' => 'hyrax/pages#show', key: 'search_tips'
    
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
