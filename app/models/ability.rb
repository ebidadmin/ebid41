class Ability
  include CanCan::Ability

  def initialize(user)
    @user = user || User.new # for guest
    @user.roles.each { |role| send(role.name.downcase) }

    if @user.roles.size == 0
      can :access, :home
      can :create, [:users, :profiles, :companies, :branches]
      can :read, [:users, :profiles, :companies, :branches]
      can :selected, :companies
    end
  end
  
  def admin
    can :access, :all
  end
  
  def buyer
    can :access, :buyer
    can :access, :cart
    can :access, [:car_brands, :car_models, :car_variants, :variances, :var_companies, :var_items, :photos]
    can [:create, :read, :update, :search, :cancel], :car_parts
    can [:create, :update, :add_photos, :save_photos, :attach_photos, :put_online, :reveal, :relist], :entries
    can [:create, :read, :update, :add, :cancel, :add_specs, :save_specs, :destroy], :line_items
    can :accept, :bids
    can [:create, :update, :read, :print, :change_status, :cancel, :confirm_cancel], :orders, user_id: @user.id
    can [:create, :read, :update, :destroy, :view, :close], :messages
    can :print, :fees
    can :read, :ratings
    can :update, :users#, id: user.id
    can :access, :companies, id: @user.company.id
    can [:access, :update], :branches, id: @user.branch.id
  end
  
  def powerbuyer
    buyer
    can [:rebid, :destroy], :entries
    can [:create, :update, :read, :print, :change_status, :cancel, :confirm_cancel], :orders
    can [:access, :update], :branches, company_id: @user.company.id
    can :create, :branches
    can :access, :users, profile: { company_id: @user.company.id }
    can :access, :profiles, company_id: @user.company.id
    can [:read, :create, :update], [:users, :profiles]
  end
  
  def seller
    can :access, :seller
    can :access, :bids
    can :read, [:entries, :photos]
    can [:read, :accept, :print, :change_status, :cancel, :confirm_cancel], :orders
    can :confirm_payment, :orders
    can [:create, :read, :update, :destroy, :view, :close], :messages
    can :update, :users, id: @user.id
    can :update, :profiles, user_id: @user.id
    can :access, :ratings
    can :selected, [:companies, :car_brands]
    can :print, :fees
  end
end
