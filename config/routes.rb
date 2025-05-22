Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root to: proc { [ 200, {}, [ 'OK' ] ] }
  mount ActionCable.server => "/cable"

  namespace :api do
    namespace :v1 do
      resources :users, only: [ :create, :index ]
      resources :rooms, only: [ :index, :create, :show ]
      resources :messages, only: [ :create, :index ]

      post "rooms/find_or_create", to: "rooms#find_or_create"

      get "users/chat_partners", to: "users#chat_partners"
    end
  end
end
