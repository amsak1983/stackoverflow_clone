Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :attachments, only: :destroy

  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      member do
        patch :set_best
      end
    end
  end
end
