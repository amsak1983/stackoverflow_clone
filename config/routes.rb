Rails.application.routes.draw do
  devise_for :users

  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :rewards, only: :index

  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :comments, only: [ :create, :destroy ]
    resources :votes, only: [ :destroy ], defaults: { votable: "question" } do
      collection do
        post :up
        post :down
      end
    end

    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      resources :comments, only: [ :create, :destroy ]
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
end
