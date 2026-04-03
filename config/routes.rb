Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Authentication (Devise)
  devise_for :users, path: "", path_names: {
    sign_in: "sign_in",
    sign_out: "sign_out",
    sign_up: "sign_up"
  }

  # Onboarding
  resource :onboarding, only: [ :show ], controller: "onboarding" do
    post :update_step
    post :skip_step
  end

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard
  get "analytics", to: "analytics#index", as: :analytics

  # Profile
  resource :profile, only: [ :show, :edit, :update ] do
    post :upload_resume
    post :structure_with_ai
    resources :sections, controller: "profile_sections", only: [ :create, :destroy ] do
      resources :entries, controller: "profile_entries", only: [ :create, :update, :destroy ]
    end
  end

  # Job Listings
  resources :job_listings, only: [ :index, :show ] do
    member do
      patch :update_status
      post :generate_cover_letter
    end
    collection do
      post :bulk_update
      get :export
    end
  end

  # Job Applications
  resources :job_applications, only: [ :index, :show, :create ] do
    member do
      post :retry_application
    end
  end

  # Job Sources & Search Criteria
  resources :job_sources do
    resources :scan_runs, controller: "job_scan_runs", only: [ :index, :create, :show ]
    member do
      patch :toggle
    end
  end
  resources :job_search_criteria do
    member do
      patch :set_default
    end
  end

  # Interventions
  resources :interventions, only: [ :index, :show ] do
    member do
      patch :resolve
      patch :dismiss
    end
  end

  # Admin
  namespace :admin do
    root "dashboard#index"
    resources :users, only: [ :index, :show ] do
      member { patch :toggle_role }
    end
    get "api_keys", to: "api_keys#index", as: :api_keys
    patch "api_keys", to: "api_keys#update"
    post "api_keys/test_connection", to: "api_keys#test_connection", as: :test_connection_api_keys
    resources :llm_interactions, only: [ :index, :show ]
    resources :llm_models, only: [ :index, :update ] do
      collection do
        post :sync
        post :verify_all
      end
      member do
        post :verify_one
      end
    end
    resources :scan_runs, only: [ :index, :show ]
  end

  # Settings
  resource :settings, only: [ :edit, :update ]

  # Defines the root path route ("/")
  root "home#index"
end
