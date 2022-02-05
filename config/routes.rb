Rails.application.routes.draw do
  mount Rswag::Ui::Engine => '/api-docs'
  mount Rswag::Api::Engine => '/api-docs'

  defaults format: :json do
    post 'auth/login'
    delete 'auth/logout'
    post 'auth/token', to: 'auth#refresh_token'
  end

  post 'registration/authentication', to: 'registration#sign_up_authentication'
  post 'registration/sign_up', to: 'registration#confirm_sign_up'
  post 'password/forgot'
  post 'password/reset'

  scope module: :admin, path: '/admin' do
    resources :users
  end

  resources :users
  resources :joggings

  get '/reports', to: "reports#index"

end
