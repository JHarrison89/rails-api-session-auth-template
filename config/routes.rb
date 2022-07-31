Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  defaults format: :json do
    resources :users, only: [:create]
    resources :events, only: [:index, :create]
    resource :session, only: [:create, :destroy]

    post 'password/forgot', to: 'password#forgot'
    post 'password/reset', to: 'password#reset'
  end
end
