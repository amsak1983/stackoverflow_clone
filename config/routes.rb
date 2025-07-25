Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :questions, only: [ :index, :new, :create, :show, :destroy ] do
    resources :answers, only: [ :create, :destroy ], shallow: true
  end
end
