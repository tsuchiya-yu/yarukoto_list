Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "/.well-known/appspecific/com.chrome.devtools.json",
      to: proc { [204, { "Content-Type" => "application/json" }, ["{}"]] }

  get "/login", to: "sessions#new"
  post "/login", to: "sessions#create"
  delete "/logout", to: "sessions#destroy"

  get "/register", to: "registrations#new"
  post "/register", to: "registrations#create"

  post "/templates/:template_id/copy", to: "user_lists#create", as: :copy_template

  scope module: :public do
    get "/lists", to: "templates#index", as: :public_templates
    get "/lists/:id", to: "templates#show", as: :public_template
  end

  root "public/home#index"
end
