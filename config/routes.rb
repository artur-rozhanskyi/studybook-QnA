Rails.application.routes.draw do
  devise_for :users
  resources :questions, shallow: true do
    resources :answers do
      resources :comments
    end
    resources :comments
  end

  root 'questions#index'

  mount ActionCable.server => '/cable'
end
