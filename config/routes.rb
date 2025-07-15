Rails.application.routes.draw do

  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"
  
  resources :questions, only: [:index, :new, :create, :show] do
    resources :answers, only: [:create], shallow: true
  end
end
