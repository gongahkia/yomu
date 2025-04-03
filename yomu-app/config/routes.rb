Rails.application.routes.draw do
  devise_for :users

  root 'dashboard#index'

  get 'dashboard', to: 'dashboard#index'

  resources :books, only: [:index, :show]
  resources :reading_sessions, only: [:new, :create]
  resources :reviews, only: [:new, :create]

  get 'trivia', to: 'trivia#index'
  post 'trivia/verify', to: 'trivia#verify'

  get 'profile', to: 'profile#show'
  get 'profile/:id', to: 'profile#show', as: 'user_profile'
  patch 'profile', to: 'profile#update'

  get 'leaderboard', to: 'leaderboard#index'

  get 'ocr/upload', to: 'ocr#upload', as: 'upload_ocr'
  post 'ocr/process', to: 'ocr#process_image', as: 'process_ocr'
end
