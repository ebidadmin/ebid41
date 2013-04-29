class BuyerController < ApplicationController
  before_filter :initialize_cart, :only => [:show]
  before_filter :search_car_models, only: [:entries, :orders]

  def dashboard
    @presenter = BuyerPresenter.new(current_user)
    if current_user.has_role? :powerbuyer
      @messages = Message.where(receiver_company_id: current_user.company).order('id DESC')
    else
      @messages = Message.where(receiver_id: current_user).order('id DESC')
    end
  end
  
  def entries
    store_location
    @q = Entry.by_this_buyer(current_user).find_status(params[:s], true).search(params[:q])
    @entries = @q.result.includes(:user, :car_brand, :car_model, :bids, :orders, :messages, :variance).paginate(page: params[:page], per_page: 12)#.order('bid_until DESC')

    if params[:q] && params[:q][:car_brand_id_eq].present?
      @car_models = CarModel.where(car_brand_id: params[:q][:car_brand_id_eq])
    else
      @car_models = []
    end
  end

  def show
    @entry = Entry.find(params[:id])
    if (@entry.company_id == current_user.company.id || can?(:access, :all))
      @line_items = @entry.line_items.includes(:car_part, :bids, :order).order('status DESC')
    else
      flash[:error] = "You are not allowed to access that Entry."
      redirect_back_or_default buyer_entries_path(s: 'online')
    end
  end

  def print
    show
    if can? :access, :all
      @messages = @entry.messages
    else          
      @messages = @entry.messages.restricted(current_user.company)
    end
    render :layout => 'print'
  end

  def orders
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s]).by_this_buyer(current_user)
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :seller_company, :messages).paginate(page: params[:page], per_page: 8)

    @seller_company = Company.find(params[:q][:seller_company_id_matches]).nickname if params[:q] && params[:q][:seller_company_id_matches].present?
  end

  def fees
    @q = Fee.for_decline.by_this_buyer(current_user).filter_period(params[:q]).search(params[:q])
    @all_fees ||= @q.result
    @fees = @all_fees.includes([:entry => [:user, :car_brand, :car_model]], [:line_item => :car_part]).paginate(page: params[:page], per_page: 15)

    @branch = Branch.find(params[:q][:buyer_branch_id_eq]).name if params[:q] && params[:q][:buyer_branch_id_eq].present?
    seller_present?
  end
  
  def messages
    if current_user.has_role? :powerbuyer
      @q = Message.restricted(current_user.company).search(params[:q])
    else
      @q = Message.this_user(current_user).search(params[:q])
    end
    @messages = @q.result.order('created_at DESC').page(params[:page]).per_page(20)
    @companies = Company.where(primary_role: 2)
  end
end
