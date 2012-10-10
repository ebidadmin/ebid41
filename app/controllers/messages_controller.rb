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
    @message = current_user.messages.build(
      user_company_id: current_user.company.id, user_type: current_user.roles.first.name,
      entry_id: params[:e], order_id: params[:o], parent_id: params[:parent_id],
      receiver_id: params[:r], receiver_company_id: params[:rc]
      )
  end

  def create
    # raise params.to_yaml
    @message = current_user.messages.build(params[:message])
    case params[:message][:msg_for]
    when 'Admin'
      @message.receiver_id = 1
      @message.receiver_company_id = 1
    when 'Buyer'
      @entry = Entry.find(params[:message][:entry_id])
      @message.receiver_id = @entry.user_id
      @message.receiver_company_id = @entry.company_id
    end
 
    respond_to do |format|
      if @message.save
        format.html { redirect_to :back, notice: "Message sent." }
        format.js { redirect_to action: :view, id: @message.entry_id }
      else
        format.html { redirect_to :back, notice: "Failed to save message. Try again." }
        format.js { render action: :new }
      end
    end

   end

  def edit
    @message = Message.find(params[:id])
  end

  def update
    @message = Message.find(params[:id])
    if @message.update_attributes(params[:message])
      respond_to do |format|
        format.html { redirect_to :back, notice: "Successfully updated message." }
        format.js { render action: :close}
      end
    else
      render :action => 'edit'
    end
  end

  def destroy
    @message = Message.find(params[:id])
    @message.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: "Deleted the message." }
      format.js
    end
  end
  
  def view
    @entry = Entry.find(params[:id])
    if can? :access, :all
      @messages = Message.where(entry_id: @entry)
    else
      @messages = Message.where(entry_id: @entry).pvt.restricted(current_user.company)
    end
  end
  
  def close
    @message = Message.find(params[:id])
  end
  
end
