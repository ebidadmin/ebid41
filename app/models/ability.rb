class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new 
    
    if user.has_role? :admin
      can :access, :all
    elsif user.has_role? :buyer
      can :access, :buyer
      can :access, :cart
      can :access, [:car_brands, :car_models, :car_variants, :regions]
      can [:create, :read, :update, :search, :cancel], :car_parts
      can [:create, :update, :add_photos, :save_photos, :attach_photos, :put_online, :reveal, :relist, :destroy], :entries
      can [:create, :read, :update, :add, :cancel, :add_specs, :save_specs, :destroy], :line_items
      can :accept, :bids
      can [:create, :update, :read, :print, :change_status, :cancel, :confirm_cancel], :orders#, user_id: user.id
      can :access, [:variances, :var_companies, :var_items, :photos]
      can [:create, :read, :update, :destroy, :view, :close], :messages
      can :print, :fees
      can :access, :ratings
      can :update, :users#, id: user.id
      can :access, :companies#, id: user.company.id
      can :read, :branches
    elsif user.has_role? :powerbuyer
      buyer
      can :rebid, :entries
    elsif user.has_role? :seller
      can :access, :seller
      can :access, [:home, :bids]
      can :read, :entries
      can [:read, :accept, :print, :change_status, :cancel, :confirm_cancel], :orders
      can :confirm_payment, :orders
      can [:create, :read, :update, :destroy, :view, :close], :messages
      can :update, [:users, :profiles]#, id: user.id
      can :access, :ratings
      can :selected, [:companies, :car_brands]
      can :print, :fees
    else
      can :access, :home
      can :create, [:users, :profiles, :companies, :branches]
      can :read, [:users, :profiles, :companies, :branches]
      can :selected, :companies
    end
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are
    # :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. If you pass
    # :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details: https://github.com/ryanb/cancan/wiki/Defining-Abilities
  end
end
