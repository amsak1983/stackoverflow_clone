# Application routes configuration
Rails.application.routes.draw do
  # Authentication
  devise_for :users

  # Health check for monitoring
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "questions#index"

  # Standalone resources
  resources :attachments, only: :destroy
  resources :links, only: :destroy
  resources :rewards, only: :index

  # Questions with nested resources
  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    # Voting for questions
    resources :votes, only: [ :create, :destroy ], defaults: { votable: "question" }

    # Answers with shallow nesting
    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      member do
        patch :set_best
      end

      # Voting for answers
      resources :votes, only: [ :create, :destroy ], defaults: { votable: "answer" }
    end
  end
end
