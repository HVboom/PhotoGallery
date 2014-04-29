PhotoGallery::Application.routes.draw do
  devise_for :users
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
mount MailPreview => 'mail_view' if Rails.env.development?end
