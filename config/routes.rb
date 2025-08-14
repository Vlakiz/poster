Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions" }\

  get "users/:id", to: "users#show", constraints: { id: /\d+/ }, as: "user"
  get "users/:nickname", to: "users#show", constraints: { nickname: /\w+/ }, as: "nickname"
  resources :users, only: [ :edit, :update ] do
    member do
      delete :remove_avatar

      post :follow, to: "subscriptions#create"
      delete :unfollow, to: "subscriptions#destroy"
    end

    collection do
      get "profile/new", action: :new_profile, as: "new_profile"
      post "profile/create", action: :create_profile, as: "create_profile"
    end
  end

  resources :posts, except: [ :index ]  do
    post :like, to: "likes#create", as: :like
    delete :like, to: "likes#destroy", as: :unlike

    resources :comments, shallow: true do
      post :like, to: "likes#create", as: :like
      delete :like, to: "likes#destroy", as: :unlike
      get :replies
    end
  end
  get "/:feed", to: "posts#feed", as: :feed, constraints: { feed: /(hot|new|subscriptions|best)/ }

  root to: redirect("/hot")

  get "up" => "rails/health#show", as: :rails_health_check
end
