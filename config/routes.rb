require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  resource :cart do
    put :add_item, on: :collection
    delete '/:product_id', to: 'carts#remove_product'
  end

  get "up" => "rails/health#show", as: :rails_health_check

  root "rails/health#show"
end
