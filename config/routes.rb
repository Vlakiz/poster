Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }\

  resources :users, only: [ :show, :edit, :update ] do
    member do
      delete :remove_avatar
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

    resources :comments, except: [ :show ] do
      post :like, to: "likes#create", as: :like
      delete :like, to: "likes#destroy", as: :unlike
    end
  end

  root to: "posts#feed"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
