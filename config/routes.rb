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
      resources :products, only: [ :index, :show, :create, :update ]
      resources :unbundles, only: [] do
        collection do
          post "unbundle", to: "unbundles#unbundle_product"
          get "bundles", to: "unbundles#bundles"
        end
      end
      resources :inventory_locations, only: [ :show ] do
        collection do
          get "by_warehouse", to: "inventory_locations#inventory_locations_by_warehouse"
        end
        member do
          get "history", to: "inventory_locations#history"
        end
      end
      resources :inventory_transfers, only: [] do
        collection do
          get "locations_to_transfer", to: "inventory_transfers#locations_to_transfer"
          post "transfer_inventory", to: "inventory_transfers#transfer_inventory"
        end
      end
      resources :warehouses, only: [ :index, :show ]
    end
  end
end
