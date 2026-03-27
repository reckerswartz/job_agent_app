Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication
  get  "sign_in",  to: "sessions#new",           as: :sign_in
  post "sign_in",  to: "sessions#create"
  get  "sign_up",  to: "registrations#new",       as: :sign_up
  post "sign_up",  to: "registrations#create"
  delete "sign_out", to: "sessions#destroy",      as: :sign_out

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Defines the root path route ("/")
  root "home#index"
end
