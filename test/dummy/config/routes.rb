
Rails.application.routes.draw do
  mount InOrder::Engine => "/in_order"

  resources :owners do
    resources :elements, only: %i(index create destroy)
  end

  resources :subjects

  root to: 'owners#index'
end
