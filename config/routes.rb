Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check
  get "/.well-known/appspecific/com.chrome.devtools.json",
      to: proc { [204, { "Content-Type" => "application/json" }, ["{}"]] }

  root "home#index"
end
