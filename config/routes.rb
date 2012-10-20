Ebid41::Application.routes.draw do


  resources :photos

  get "sessions/new"

  get "admin/nav"

  devise_for :users, path: :account, controllers: {sessions: "sessions"}
  resources :users, :shallow => true do
    resources :ratings, :only => :index
    resources :entries
  end

  scope 'buyer' do
    get 'dashboard' => 'buyer#dashboard', as: :buyer_dashboard
    get 'entries(/:s)' => 'buyer#entries', as: :buyer_entries
    get 'show/:id' => 'buyer#show', as: :buyer_show
    get 'show/:id/print' => 'buyer#print', as: :print_entry
    get 'reactivate/:id' => 'buyer#reactivate', as: :buyer_reactivate
    get 'orders(/:s(/:id))' => 'buyer#orders', as: :buyer_orders
    get 'fees(/:t)' => 'buyer#fees', as: :buyer_fees
    get 'messages(/:t)' => 'buyer#messages', as: :buyer_messages
    get 'surrender/:id' => 'buyer#surrender', as: :surrender_parts
    post 'surrender_letter/:id' => 'buyer#surrender_letter', as: :surrender_letter
  end

  scope 'seller' do
    get 'dashboard' => 'seller#dashboard', as: :seller_dashboard
    get 'entries(/:s)' => 'seller#entries', as: :seller_entries
    get 'worksheet' => 'seller#worksheet', as: :seller_worksheet
    get 'show/:id' => 'seller#show', as: :seller_show
    get 'bids' => 'seller#bids', as: :seller_bids
    get 'orders(/:s(/:id))' => 'seller#orders', as: :seller_orders
    get 'fees(/:t)' => 'seller#fees', as: :seller_fees
    get 'messages(/:t)' => 'seller#messages', as: :seller_messages
  end
  
  scope 'admin' do
    get 'dashboard' => 'admin#dashboard', as: :admin_dashboard
    get 'update_ratios' => 'admin#update_ratios', as: :update_ratios
    get 'expire_entries' => 'admin#expire_entries', as: :expire_entries
    get 'tag_payments' => 'admin#tag_payments', as: :tag_payments
    get 'send_payment_reminder' => 'admin#send_payment_reminder', as: :send_payment_reminder
    get 'delivery_reminder' => 'admin#delivery_reminder', as: :delivery_reminder
    get 'fix' => 'admin#fix', as: :fix
  end


  get "cart/add"
  get "cart/remove"
  get "cart/clear"

  resources :variances, only: :index do
    get :summarize, on: :collection
  end
  resources :entries, shallow: true do
    member do
      get :put_online
      get :reveal
      get :relist
      get :reactivate
      get :rebid
      get :print
      get :add_photos
      get :attach_photos
      put :save_photos
    end
    resources :variances, except: :index
  end

  resources :var_items
  resources :var_companies do
    get :add, on: :collection
  end

  scope 'fees' do
    get '/:t' => 'fees#index', as: :fees
    get '/:t/print' => 'fees#print', as: :print_fees
  end
  resources :fees

  resources :messages do
    collection do
      get :view
      get :close
    end
 end

  resources :orders do
    member do
      get :accept
      get :change_status
      put :buyer_paid
      get :print
      get :cancel
      put :confirm_cancel
    end
    collection do
      get :auto_paid
    end
    resources :ratings
  end
  resources :ratings, shallow: true do
    get :auto, on: :collection
  end

  resources :bids do
    collection do
      post :accept
    end
  end

  resources :line_items do
    collection do
      get :add
      get :cancel
    end
  end

  resources :profiles

  resources :ranks

  resources :branches

  resources :companies

  resources :car_parts do
    collection do
      get :search
      # get :add_more
      get :cancel
    end
  end


  resources :cities

  resources :car_variants


  resources :car_brands do
    get :selected, on: :member
  end
  
  resources :car_models do
    get :selected, on: :member
  end
  
  # authenticated :user do
  #   root :to => 'home#index'
  # end
  root :to => 'home#index'
end
