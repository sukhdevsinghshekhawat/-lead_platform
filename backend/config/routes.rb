Rails.application.routes.draw do
  root to: redirect("/api/up")
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    post "login", to: "auth#login"
    get "me", to: "auth#me"

    resources :users, only: [:index, :create, :destroy]
    resources :leads, only: [:index, :show, :create, :update, :destroy] do
      member do
        patch :update_status
        patch :assign
        post :add_note
      end
    end

    get "dashboard", to: "dashboard#index"
  end
end
