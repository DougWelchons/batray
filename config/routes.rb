Rails.application.routes.draw do
  devise_for :users

  root to: "dashboard#index"

  resources :projects do
    member do
      post :duplicate
      patch :discard
    end
    resources :bid_submissions, except: [ :index, :show ] do
      member do
        patch :discard
      end
    end
  end

  resources :contractors
  resources :bid_submissions, only: [] do
    collection do
      get :index
    end
  end

  namespace :admin do
    resources :users
  end

  get "dashboard", to: "dashboard#index", as: :dashboard

  # SPA routes - catch all routes under /spa
  get "spa", to: "spa#index"
  get "spa/*path", to: "spa#index"

  # API endpoints for SPA
  namespace :api do
    namespace :v1 do
      resource :current_user, only: [ :show ]
      resources :users, only: [ :index, :show, :create, :update, :destroy ]
      resources :projects, only: [ :index, :show, :create, :update, :destroy ]
      resources :contractors, only: [ :index, :show, :create, :update, :destroy ] do
        resources :contacts, only: [ :index ]
      end
      resources :contacts, only: [ :create, :update, :destroy ]
      resources :bid_submissions, only: [ :index, :show, :create, :update, :destroy ]
    end
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
