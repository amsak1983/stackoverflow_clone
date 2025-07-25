Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :questions, only: [ :index, :new, :create, :show ] do
    resources :answers, only: [ :create ], shallow: true do
      member do
        patch :mark_as_best
      end
    end
  end
  
  resources :answers, only: [ :edit, :update, :destroy ]
end
