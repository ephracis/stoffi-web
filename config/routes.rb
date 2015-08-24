Stoffi::Application.routes.draw do

  scope '(:l)', l: /us|se/ do

    ##########################
    # USER ACCOUNTS 
    ##########################
    scope module: :accounts do
      
      # set up devise
      devise_for :user, path: '', skip: [ :registration, :passwords, :unlocks ],
      sign_out_via: [ :get, :delete ],
      path_names:
      {
        sign_in: :login,
        sign_out: :logout
      }
    
      # custom devise routes
      as :user do
        post   'forgot',         to: 'passwords#create',   as: :user_password
        get    'forgot',         to: 'passwords#new',      as: :new_user_password
        get    'reset',          to: 'passwords#edit',     as: :edit_user_password
        patch  'reset',          to: 'passwords#update'
        put    'reset',          to: 'passwords#update'
      
        get    'cancel',         to: 'accounts#cancel',    as: :cancel_user_registration
        post   'join',           to: 'accounts#create',    as: :user_registration
        get    'join',           to: 'accounts#new',       as: :new_user_registration
        get    'settings',       to: 'accounts#edit',      as: :edit_user_registration
        patch  'settings(/:id)', to: 'accounts#update',    as: :update_user_registration
        put    'settings(/:id)', to: 'accounts#update'
        delete 'leave',          to: 'accounts#destroy',   as: :leave
      
        post   'unlock',         to: 'unlocks#create'
        get    'unlock',         to: 'unlocks#new',        as: :new_user_unlock
        get    'unlock(/:id)',   to: 'unlocks#show',       as: :user_unlock
      
        get    'profile(/:id)',  to: 'accounts#show',      as: :user
        get    'dashboard',      to: 'accounts#dashboard', as: :dashboard
      
        get    'me/playlists',   to: 'playlists#by'
        get    'me',             to: 'accounts#show',      as: :me
      end
      
      # oauth
      match 'oauth/:action',   to: 'oauth', via: [:get, :post], as: :authorize
      
      # handle failed omniauth
      get    'auth/failure',   to: 'sessions#new'
    
      resources :devices
      resources :links, only: [:index, :show, :create, :update, :destroy]
    end
    
    ##########################
    # MEDIA RESOURCES 
    ##########################
    scope module: :media do
      resources :sources, :artists, :events, :genres
    
      resources :songs do
        member do
          get 'find_duplicates'
          patch 'mark_duplicates'
        end
      end
    
      resources :listens do
        member do
          post 'end'
        end
      end
    
      resources :albums do
        member do
          patch 'sort'
        end
      end
    
      resources :playlists do
        member do
          put 'follow'
          patch 'sort'
        end
        collection do
          get 'following'
          get 'mine'
        end
      end
    
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
    
    # static pages
    %w[news tour get download checksum contact about legal money donate remote
      mail old barebone].each do |page|
      get "/#{page}", to: "pages##{page}", as: page.to_sym
    end
    
    # search
    get '/search/suggest'
    get '/search/fetch'
    get '/search/(:categories)', to: 'search#index', as: :search
    
    # # error pages
    %w( 400 403 404 422 500 502 503 ).each do |code|
      get code, to: "errors#show", code: code
    end
    
    # root path
    get '/', to: 'pages#index', as: :root
  end
end
