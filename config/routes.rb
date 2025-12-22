Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "/.well-known/appspecific/com.chrome.devtools.json",
      to: proc { [204, { "Content-Type" => "application/json" }, ["{}"]] }

  get "/login", to: "sessions#new", as: :login
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/signup", to: "registrations#new", as: :signup
  post "/signup", to: "registrations#create"

  resources :user_lists, only: %i[index create]

  scope module: :public do
    get "/lists", to: "templates#index", as: :public_templates
    get "/lists/:id", to: "templates#show", as: :public_template
  end

  root "public/home#index"
end
