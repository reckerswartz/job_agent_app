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

  # Dashboard
  get "dashboard", to: "dashboard#index", as: :dashboard

  # Profile
  resource :profile, only: [:show, :edit, :update] do
    post :upload_resume
    resources :sections, controller: "profile_sections", only: [:create, :destroy] do
      resources :entries, controller: "profile_entries", only: [:create, :update, :destroy]
    end
  end

  # Job Listings
  resources :job_listings, only: [:index, :show] do
    member do
      patch :update_status
    end
  end

  # Job Applications
  resources :job_applications, only: [:index, :show, :create] do
    member do
      post :retry_application
    end
  end

  # Job Sources & Search Criteria
  resources :job_sources do
    resources :scan_runs, controller: "job_scan_runs", only: [:index, :create, :show]
    member do
      patch :toggle
    end
  end
  resources :job_search_criteria do
    member do
      patch :set_default
    end
  end

  # Settings
  resource :settings, only: [:edit, :update]

  # Defines the root path route ("/")
  root "home#index"
end
