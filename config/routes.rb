Rails.application.routes.draw do
  devise_for :users
  resources :questions do
    resources :answers do
      resources :comments, shallow: true
    end
    resources :comments, shallow: true
  end

  root 'questions#index'

  mount ActionCable.server => '/cable'
end
