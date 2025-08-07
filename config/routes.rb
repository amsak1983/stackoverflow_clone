Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :rewards, only: :index

  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :votes, only: [ :create, :destroy ], defaults: { votable: "question" }

    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      member do
        patch :set_best
      end

      resources :votes, only: [ :create, :destroy ], defaults: { votable: "answer" }
    end
  end
end
