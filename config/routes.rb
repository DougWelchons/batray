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

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check
end
