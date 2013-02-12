class SellerController < ApplicationController
  before_filter :search_car_models, only: [:entries, :bids, :orders]
  before_filter :check_user_enabled

  def dashboard
    @presenter = SellerPresenter.new(current_user)
    @messages = Message.where(receiver_company_id: current_user.company).order('id DESC')
  end
  
  def entries
    @q ||= Entry.find_status(params[:s]).search(params[:q])
    @entries = @q.result.joins{company.friends}.where(:friendships => { :friend_id => current_user.company.id}).includes(:photos, :car_brand, :car_model, :line_items, :bids, :messages).page(params[:page]).per_page(8)

  end

  def worksheet
    # raise params.to_yaml
    if params[:entries] 
      @entries = Entry.where(:id => params[:entries])
    else
      @entries = Entry.online.active.unexpired.joins{company.friends}.where(:friendships => { :friend_id => current_user.company.id}).includes(:line_items)
    end
    @company = current_user.company
    render layout: 'print'
  end

  def bids
    @q = Bid.unscoped.search(params[:q])
    @bids = @q.result.where(user_id: current_user.company.users).includes([:entry => [:car_brand, :car_model]], [:line_item => :car_part], :user).order('created_at DESC').page(params[:page]).per_page(15)
  end

  def show
    @entry = Entry.find(params[:id], include: [:line_items => [:car_part, :bids]])
    unless @entry.company.friends.include?(current_user.company) || can?(:access, :all)
      flash[:error] = "Sorry, you are not allowed to access that Entry."
      redirect_back_or_default seller_dashboard_path
    end
  end

  def orders
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s]).by_this_seller(current_user.company)
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :company, :messages).page(params[:page]).per_page(10)
 
    @buyer_company = Company.find(params[:q][:company_id_matches]).nickname if params[:q] && params[:q][:company_id_matches].present?
  end

  def fees
    @q = Fee.find_type(params[:t]).by_this_seller(current_user.company).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part], [:seller_company], :order).page(params[:page]).per_page(20)

    buyer_present?
    seller_present?
  end
  
  def messages
    @q = Message.restricted(current_user.company).search(params[:q])
    @messages = @q.result.order('created_at DESC').page(params[:page]).per_page(20)
  end
  
  
end
