# frozen_string_literal: true

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  defaults format: :json do
    resources :users, only: [:create]
    resources :events, only: %i[index create]
    resource :session, only: %i[create destroy]

    post 'password/forgot', to: 'password#forgot'
    post 'password/reset', to: 'password#reset'
  end
end
