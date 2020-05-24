Rails.application.routes.draw do
  get '/', to:'participants#entrying'

  get '/events', to:'events#index'

  get 'events/organizing'

  get 'events/new'
  post 'events/new', to:'events#new'

  get 'events/:id', to:'events#show'

  get 'events/edit/:id', to:'events#edit'
  patch 'events/edit/:id', to:'events#edit'

  get 'events/destroy/:id', to:'events#destroy'

  get '/participants/new/:id', to:'participants#new'

  get '/participants/destroy/:id', to:'participants#destroy'

  get 'participants/entry/:id', to:'participants#entry'
  patch 'participants/entry/:id', to:'participants#entry'

  get 'participants/participation/:id', to:'participants#participation'
  patch 'participants/participation/:id', to:'participants#participation'

  get 'account_expandeds/edit'
  patch 'account_expandeds/edit', to:'account_expandeds#edit'

  devise_scope :account do
    get '/accounts/sign_out' => 'devise/sessions#destroy'
  end

  devise_for :accounts
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
