class MessagesController < ApplicationController
  def index
    if can? :access, :all
      @q = Message.search(params[:q])
    else
      @q = Message.restricted(current_user.company).search(params[:q])
    end
    @messages = @q.result.order('created_at DESC').page(params[:page]).per_page(20)
    @companies = Company.where(primary_role: 2)
  end

  def show
    @message = Message.find(params[:id])
    @message.update_attribute(:read_on, Time.now) if @message.receiver == current_user && @message.read_on.blank?
    if @message.order_id.present?
      redirect_to order_path(@message.order, anchor: "message_#{@message.id}")
    elsif @message.entry_id.present?
      if can? :access, :all
         redirect_to @message.entry
      elsif can? :access, :buyer
        redirect_to buyer_show_path(@message.entry, anchor: "message_#{@message.id}")
      elsif can? :access, :seller
        redirect_to seller_show_path(@message.entry, anchor: "message_#{@message.id}")
      end
    else  
      render
    end
  end

  def new
    @entry = Entry.find(params[:e])
    @message = current_user.messages.build(
      user_company_id: current_user.company.id, user_type: current_user.roles.first.name,
      entry_id: params[:e], order_id: params[:o], parent_id: params[:parent_id],
      receiver_id: params[:r], receiver_company_id: params[:rc]
      )
  end

  def create
    # raise params.to_yaml
    @message = current_user.messages.build(params[:message])
    @entry = Entry.find(params[:message][:entry_id])
    case params[:message][:msg_for]
    when 'Admin'
      @message.receiver_id = 1
      @message.receiver_company_id = 1
    when 'Buyer'
      @message.receiver_id = @entry.user_id
      @message.receiver_company_id = @entry.company_id
    when 'Seller'
      @order = Order.find(params[:message][:order_id])
      @message.receiver_id = @order.seller_id
      @message.receiver_company_id = @order.seller_company_id
    end
 
    respond_to do |format|
      if @message.save
        format.html { redirect_to :back, notice: "Message sent." }
        if @message.order_id.present?
          format.js { redirect_to action: :view, order_id: @message.order_id }
        else
          format.js { redirect_to action: :view, id: @message.entry_id }
        end
        Notify.delay.new_message(@entry, @message)  if @message.receiver.opt_in?
      else
        format.html { redirect_to :back, notice: "Failed to save message. Try again." }
        format.js { render action: :new }
      end
    end

   end

  def edit
    store_location
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(params[:message])
      respond_to do |format|
        format.html { redirect_back_or_default messages_path }
        format.js { render action: :close }
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @entry = @message.entry
    @message.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "Deleted the message." }
      format.js
    end
  end
  
  def view
    if params[:order_id].present?
      find_order_messages
    else
      find_entry_messages
    end
    @messages.each { |m| m.update_attribute(:read_on, Time.now) if m.receiver == current_user && m.read_on.blank?}
  end
  
  def close
    @message = Message.find(params[:id])
  end
  
  private
  
  def find_order_messages
    @order = Order.find(params[:order_id])
    if can? :access, :all
      @messages = @order.messages
    else
      @messages = @order.messages.restricted(current_user.company)
    end
  end
  
  def find_entry_messages
    @entry = Entry.find(params[:id])
    if can? :access, :all
      @messages = @entry.messages
    else          
      @messages = @entry.messages.restricted(current_user.company)
    end
  end
  
end
