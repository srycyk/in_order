
InOrder::Engine.routes.draw do
  resources :elements, only: %i(create update destroy)

  resources :lists, only: %i(index create destroy) do
    post :add, on: :collection

    post :remove, on: :collection
  end
end
