class ApplicationController < ActionController::Base
  protect_from_forgery
  
  enable_authorization unless: :devise_controller?

  rescue_from CanCan::Unauthorized do |exception|
    flash[:error] = "You are not authorized for that action or page"
    if user_signed_in?
      if can? :access, :all # admin
        redirect_to admin_dashboard_path
      elsif can? :create, :entries # buyer
        redirect_to buyer_dashboard_path
      elsif can? :create, :bids # seller
        redirect_to seller_dashboard_path 
      end
    else
      redirect_to root_url
    end
  end
  
  private
  
  def after_sign_in_path_for(resource_or_scope)
    if can? :access, :all 
      admin_dashboard_path
    elsif can? :create, :entries 
      buyer_dashboard_path
    elsif can? :create, :bids 
      seller_dashboard_path
    else
      flash[:error] = "You have not been authorized to use E-Bid. Please contact the administrator at 892-5935." 
      root_path
    end
  end

  def after_sign_out_path_for(resource_or_scope)
    # root_path
    new_user_session_path
  end

  def store_location
    session['referer'] = request.env["HTTP_REFERER"]
  end

  def redirect_back_or_default(default)
    redirect_to(session['referer'] || default)
    session['referer'] = nil
  end
  
  def check_user_enabled
		unless user_signed_in? && current_user.enabled?
		  sign_out
		  flash[:error] = "Your account is NOT ENABLED. Please contact the administrator at 892-5935."
      redirect_to root_path      
    end
  end

  def initialize_cart 
    @cart = Cart.find(session[:cart_id]) 
    rescue ActiveRecord::RecordNotFound 
      @cart = Cart.create#Cart.create(user_id: current_user.id) 
      session[:cart_id] = @cart.id 
  end

  def buyer_present?
    if params[:q] && params[:q][:buyer_company_id_matches].present?
      @buyer_company = Company.find(params[:q][:buyer_company_id_matches]).nickname
    else
      if can? :access, :bids
        @buyer_company = 'all buyers'
      else
        @buyer_company = current_user.company.nickname
      end
    end
  end
 
  def seller_present?
    if params[:q] && params[:q][:seller_company_id_matches].present?
      @seller_company = Company.find(params[:q][:seller_company_id_matches]).nickname
    else
      # @seller_company = 'all sellers'
      if (can? :access, :all) || (can? :create, :entries)
         @seller_company = 'all sellers'
       else
         @seller_company = current_user.company.nickname
       end
     end
  end
  
  def search_car_models
    if params[:q] && params[:q][:car_brand_id_eq].present?
      @car_models = CarModel.where(car_brand_id: params[:q][:car_brand_id_eq]).order(:name)
    elsif params[:q] && params[:q][:entry_car_brand_id_eq].present?
      @car_models = CarModel.where(car_brand_id: params[:q][:entry_car_brand_id_eq]).order(:name)
    else
      @car_models = []
    end
  end
end
