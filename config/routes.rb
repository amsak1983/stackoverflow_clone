Rails.application.routes.draw do
  devise_for :users
  get "up" => "rails/health#show", as: :rails_health_check

  root "questions#index"

  resources :questions, only: [ :index, :new, :create, :show, :edit, :update, :destroy ] do
    member do
      delete "attachments/:attachment_id", to: "questions#remove_attachment", as: "attachment"
    end

    resources :answers, only: [ :create, :update, :destroy ], shallow: true do
      member do
        patch :set_best
        delete "attachments/:attachment_id", to: "answers#remove_attachment", as: "attachment"
      end
    end
  end
end
