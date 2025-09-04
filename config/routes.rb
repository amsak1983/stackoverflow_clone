Rails.application.routes.draw do
  use_doorkeeper
  devise_for :users, controllers: {
    omniauth_callbacks: "users/omniauth_callbacks"
  }

  resources :user_email_confirmations, path: "users/email_confirmations", controller: "users/email_confirmations", only: [ :new, :create ] do
    member do
      get :confirm
    end
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :rewards, only: :index

  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :comments, only: [ :create, :destroy ], shallow: true
    resources :votes, only: [ :destroy ], defaults: { votable: "question" } do
      collection do
        post :up
        post :down
      end
    end

    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      resources :comments, only: [ :create, :destroy ], shallow: true
      member do
        patch :set_best
      end

      resources :votes, only: [ :destroy ], defaults: { votable: "answer" } do
        collection do
          post :up
          post :down
        end
      end
    end
  end

  namespace :api do
    namespace :v1 do
      get "profiles/me", to: "profiles#me"

      resources :profiles, only: :index

      resources :questions, only: [ :index, :show, :create, :update, :destroy ] do
        resources :answers, only: [ :index, :create ]
      end

      resources :answers, only: [ :show, :update, :destroy ]
    end
  end
end
