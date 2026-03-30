Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  namespace :admin do
    root to: "dashboard#index"
    resources :stores do
      member do
        patch :verify
        patch :toggle_featured
      end
    end
    resources :users
    resources :categories
    resources :subscription_plans
  end

  namespace :vendor do
    root to: "dashboard#index"
    resource :store, only: %i[show edit update]
    resources :products do
      resources :variants, controller: "product_variants", shallow: true
    end
    resources :orders, only: %i[index show update]
    resource :pos, only: %i[show], controller: "pos" do
      post :search_products
      post :charge
      get :receipt, path: "receipt/:order_id"
    end
    resource :analytics, only: %i[show], controller: "analytics"
  end

  root "home#index"

  resources :stores, only: %i[index show]
  resources :products, only: %i[show]
  resources :orders do
    member do
      patch :cancel
    end
  end

  resource :cart, only: %i[show] do
    post :add_item
    delete :remove_item
    patch :update_item
  end

  resources :subscriptions, only: %i[index create]
  resources :reviews, only: %i[create destroy]
  resources :addresses

  post "/webhooks/stripe", to: "webhooks#stripe"

  get "up" => "rails/health#show", as: :rails_health_check
end
