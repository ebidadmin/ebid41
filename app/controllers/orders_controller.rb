class OrdersController < ApplicationController
  include ActionView::Helpers::TagHelper

  def index
    @q = Order.search(params[:q])
    @all_orders ||= @q.result.find_status(params[:s])
    @orders = @all_orders.includes([:entry => [:car_brand, :car_model, :user]], :seller_company, :messages).paginate :page => params[:page], :per_page => 10
    @companies = Company.where(primary_role: 2).includes(:users).order('users.username ASC')
  end

  def show
    @order = Order.find(params[:id], include: [:bids => [:line_item => :car_part]])
    @entry = @order.entry
    @messages = @order.messages
    render layout: 'print'
  end

  def new
    @order = Order.new
  end

  def create
    @orders = Array.new
    @entry = Entry.find(params[:id])
    winning_bids = params[:bids]
    @bids ||= Bid.find(winning_bids.collect { |k,v| k })

    # Create a unique PO per seller
    @bids.group_by(&:user).each do |bidder, bids|
      @order = @entry.orders.build(params[:entry][:order])
      @order.populate(current_user, request.remote_ip, bidder, bids, winning_bids) 
      @orders << @order
    end 

    if @orders.all?(&:valid?) 
      @entry.update_attribute(:ref_no, params[:entry][:ref_no])
      @entry.update_status unless @entry.is_online
      @orders.each { |o| Notify.delay.new_order(o) }
      unless @orders.count < 2
        flash[:success] = "Your POs have been released and will be processed right away.<br>
          Your suppliers are #{content_tag :strong, @orders.collect{ |o| o.seller.company.name }.to_sentence}. Thanks!".html_safe
      else
        flash[:success] = ("Your PO has been released and will be processed right away.<br> 
          Your supplier is #{content_tag :strong, @order.seller.company.name}. Thanks!").html_safe
      end
    else
      # TODO
      flash[:error] = "Failed to generate PO. #{content_tag :strong, 'Please make sure you input the required information'}.".html_safe
    end
    redirect_to buyer_show_path(@entry) 
  end

  def edit
    @order = Order.find(params[:id], include: [:bids => [:line_item => :car_part]])
    @bids ||= @order.bids.includes(:line_item => :car_part)
    @bidders = @bids.collect(&:user_id).uniq
    @entry = @order.entry
  end

  def update
    @order = Order.find(params[:id])
    winning_bids = params[:bids]
    @bids ||= Bid.find(winning_bids.collect { |k,v| k })

    if @order.update_attributes(params[:order])
      @bids.each do |bid|
        qty = winning_bids.fetch(bid.id.to_s)[0].to_i
        bid.update_attributes(quantity: qty, total: bid.amount * qty) if bid.quantity != qty
      end
      @order.update_attribute(:order_total, @bids.collect(&:total).sum)
      flash[:success] = "Successfully updated order."
      redirect_to @order
    else
      flash[:error] = "Failed to update PO. #{content_tag :strong, 'Please make sure you input the required information'}.".html_safe
      redirect_to :back
    end
  end

  def destroy
    @order = Order.find(params[:id])
    @order.destroy
    redirect_to orders_url, :notice => "Successfully destroyed order."
  end
  
  def accept
    @order = Order.find(params[:id])
    @entry = @order.entry
    
    if @order.update_attributes(status: "For-Delivery", confirmed: Time.now, seller_confirmation: true)
      @order.update_associated_status("For-Delivery")
      flash[:notice] = "PO has been confirmed! Please deliver ASAP. Thanks!"
    else
      flash[:error] = "Something went wrong with your request ... please try again later."
    end
    redirect_to :back
  end
  
  def change_status # For tagging of Orders
    @order = Order.find(params[:id])
    flash[:success] = @order.change_status(params[:cs])
    @order.update_associated_status(params[:cs])
    redirect_to @order#:back
  end

  def cancel
    @order = Order.find(params[:id])
    if params[:bid_ids]
      @entry = @order.entry
      @bids = Bid.find(params[:bid_ids])
      @message = current_user.messages.build(
        user_id: current_user.id, user_type: current_user.roles.first.name,
        entry_id: @entry.id
        )
      flash[:error] = "Please indicate your reason for cancelling the order."
    else
      flash[:warning] = "Please select an item you want to cancel. Use the checkboxes."
      redirect_to @order
    end
  end
  
  def confirm_cancel
    # raise params.to_yaml
    @order = Order.find(params[:id])
    @bids = Bid.find(params[:bid_ids])
    if params[:message][:message].present?
      @bids.each { |bid| bid.process_cancellation }
      @message = current_user.messages.build(params[:message])
      @message.for_cancelled_order(current_user, params[:message][:user_type], @order, @bids, params[:message][:message].capitalize)
      
      if @order.messages << @message
        flash[:error] = "Order cancelled. Sayang ..."
        redirect_to @order
      else
        redirect_to :back 
      end
    else
      flash[:error] = "Please indicate your reason for cancelling the order."
      redirect_to :back 
    end
  end
end
