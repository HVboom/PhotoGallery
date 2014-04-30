PhotoGallery::Application.routes.draw do
  resources :pictures

  resources :galleries

  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  mount MailPreview => 'mail_view' if Rails.env.development?

  root to: 'rails_admin/main#dashboard'
end
