Rails.application.routes.draw do
  mount Rswag::Ui::Engine => "/api-docs"
  mount Rswag::Api::Engine => "/api-docs"

  devise_for :users, path: "api/v1/", path_names: {
    sign_in: "login",
    sign_out: "logout",
    registration: "signup"
  }, controllers: {
    sessions: "api/v1/users/sessions",
    registrations: "api/v1/users/registrations"
  }

  namespace :api do
    namespace :v1 do
      resources :products, only: [ :index, :show, :create ]
      resources :inventory_locations, only: [ :show ] do
        collection do
          get "by_warehouse", to: "inventory_locations#inventory_locations_by_warehouse"
        end
      end
    end
  end
end
