class BuyerController < ApplicationController
  before_filter :initialize_cart, :only => [:show]

  def dashboard
    @presenter = BuyerPresenter.new(current_user)
    @messages = Message.restricted(current_user.company).limit(5).order('id DESC')
  end
  
  def entries
    store_location
    @q = Entry.by_this_buyer(current_user).find_status(params[:s], true).search(params[:q])
    @entries = @q.result.includes(:user, :car_brand, :car_model, :bids, :orders, :messages, :variance).paginate(page: params[:page], per_page: 12)#.order('bid_until DESC')
  end

  def show
    @entry = Entry.find(params[:id])
    @line_items = @entry.line_items.includes(:car_part, :bids, :order).order('status DESC')
    # respond_to do |format|
    #   format.html
    #   format.js
    # end
  end

  def print
    show
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
    @q = Message.restricted(current_user.company).search(params[:q])
    @messages = @q.result.order('created_at DESC').page(params[:page]).per_page(20)
    @companies = Company.where(primary_role: 2)
  end
end
