Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }\

  resources :users, only: [ :show, :edit, :update ] do
    member do
      delete :remove_avatar

      post :follow, to: "subscriptions#create"
      delete :unfollow, to: "subscriptions#destroy"
    end

    collection do
      get "profile/new", action: :new_profile, as: "new_profile"
      post "profile/create", action: :create_profile, as: "create_profile"
    end

    get :posts, to: "posts#index"
  end

  resources :posts  do
    post :like, to: "likes#create", as: :like
    delete :like, to: "likes#destroy", as: :unlike

    resources :comments do
      post :like, to: "likes#create", as: :like
      delete :like, to: "likes#destroy", as: :unlike
    end
  end

  root "posts#feed"

  get "up" => "rails/health#show", as: :rails_health_check
end
