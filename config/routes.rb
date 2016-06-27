require 'split/landing_page'

Stoffi::Application.routes.draw do
  
  # concerns
  concern :followable do
    put :follow, on: :member
  end
  
  concern :sortable do
    patch :sort, on: :member
  end
  
  concern :sourceable do
    resources :sources
  end
  
  concern :imageable do
    resources :images
  end
  
  # static pages
  %w(contact about legal old barebone music donate youtube).each do |page|
    get "/#{page}", to: "static##{page}", as: page.to_sym
  end

  # send message
  post '/contact', to: "static#mail"
  
  # A/B testing dashboard
  mount Split::Dashboard, at: 'admin/split'
  
  # search
  get '/search', to: 'search#index'
  get '/search/suggestions'
  
  # # error pages
  %w( 400 403 404 422 500 502 503 ).each do |code|
    get code, to: "errors#show", code: code
  end

  # account management
  scope module: :accounts do
    
    # set up devise
    devise_for :user, path: '', skip: [ :registration, :passwords, :unlocks ],
    sign_out_via: [ :get, :delete ],
    path_names:
    {
      sign_in: :login,
      sign_out: :logout
    }
    
    # oauth
    match 'oauth/:action', controller: 'oauth', via: [:get, :post], as: :authorize
    
    # omniauth
    get 'auth/:provider/callback', to: 'links#create'
    get 'auth/failure', to: 'sessions#new'
    
    # links to other accounts
    resources :links, except: [:edit, :new]
  
    # custom devise routes
    as :user do
      # password management
      post   'forgot',           to: 'passwords#create',   as: :user_password
      get    'forgot',           to: 'passwords#new',      as: :new_user_password
      get    'reset',            to: 'passwords#edit',     as: :edit_user_password
      patch  'reset',            to: 'passwords#update'
      put    'reset',            to: 'passwords#update'
    
      # account management
      get    'cancel',           to: 'accounts#cancel',    as: :cancel_user_registration
      post   'join',             to: 'accounts#create',    as: :user_registration
      get    'join',             to: 'accounts#new',       as: :new_user_registration
      get    'settings(/:tab)',  to: 'accounts#edit',      as: :edit_user_registration
      patch  'settings(/:id)',   to: 'accounts#update',    as: :update_user_registration
      put    'settings(/:id)',   to: 'accounts#update'
      delete 'leave',            to: 'accounts#destroy',   as: :leave
    
      # lock management
      post   'unlock',           to: 'unlocks#create'
      get    'unlock',           to: 'unlocks#new',        as: :new_user_unlock
      get    'unlock(/:id)',     to: 'unlocks#show',       as: :user_unlock
    
      # custom paths
      get    'dashboard(/:tab)', to: 'accounts#dashboard', as: :dashboard
      get    'me',               to: 'accounts#show',      as: :me
    end
  end
  
  # media resources
  scope module: :media do
    resources :events, :genres, :songs, :artists, concerns: [:sourceable, :imageable]
    resources :albums, concerns: [:sortable, :sourceable, :imageable]
  end
  
  # apps
  resources :apps do
    member do
      delete 'revoke'
    end
  end
  
  # shares
  resources :shares, except: [:new, :edit]
  
  # charts
  namespace :charts do
    get 'listens_for_user'
    get 'songs_for_user'
    get 'artists_for_user'
    get 'albums_for_user'
    get 'playlists_for_user'
    get 'genres_for_user'
    get 'top_listeners'
    get 'active_users'
  end
  
  get 'playlists', to: 'static#music'
  post 'playlists', to: 'media/playlists#create'
  
  # user pages
  scope ':user_slug' do
    
    as :user do
      scope module: :accounts do
        get '(:tab)', to: 'accounts#show', as: :user, constraints:
          { tab: /listens|activity|toplists/ }
        get 'devices', to: 'accounts#dashboard', as: :devices, tab: :devices
        resources :devices, except: :index
      end
    end
    
    scope module: :media do
      resources :playlists, only: [:new, :create]
      get    ':playlist_slug',        to: 'playlists#show',   as: :playlist
      put    ':playlist_slug/follow', to: 'playlists#follow', as: :follow_playlist
      patch  ':playlist_slug/sort',   to: 'playlists#sort',   as: :sort_playlist
      get    ':playlist_slug/edit',   to: 'playlists#edit',   as: :edit_playlist
      post   ':playlist_slug',        to: 'playlists#update'
      put    ':playlist_slug',        to: 'playlists#update'
      patch  ':playlist_slug',        to: 'playlists#update'
      delete ':playlist_slug',        to: 'playlists#destroy'
      resources :listens do
        post :end, on: :member
      end
    end
    
  end
  
  # root path
  #
  # splitted for A/B testing
  constraints(RootConstraintAbout.new) do
    get '/', to: 'static#about'
  end
  constraints(RootConstraintMusic.new) do
    get '/', to: 'static#music'
  end
  constraints(RootConstraintSearch.new) do
    get '/', to: 'search#index'
  end
  constraints(RootConstraintDashboard.new) do
    devise_scope :user do
      get '/', to: 'accounts/accounts#dashboard'
    end
  end
end
