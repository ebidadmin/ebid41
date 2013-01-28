class LineItemsController < ApplicationController
  before_filter :initialize_cart, only: [:create, :add]

  def index
    @line_items = LineItem.limit(5)
  end

  def show
    @line_item = LineItem.find(params[:id])
  end

  def new
    @line_item = LineItem.new
  end

  def create
    @entry = Entry.find(params[:id])
    @entry.add_line_items_from_cart(@cart)
    @line_items = @entry.line_items.includes(:car_part, :bids, :order).order('status DESC')
  end

  def edit
    @line_item = LineItem.find(params[:id])
  end

  def update
    @line_item = LineItem.find(params[:id])
    if @line_item.update_attributes(params[:line_item])
      redirect_to @line_item, :notice  => "Successfully updated line item."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @line_item = LineItem.find(params[:id])
    @line_item.destroy
    redirect_to line_items_url, :notice => "Successfully destroyed line item."
  end
  
  def add
    @entry = Entry.find(params[:id], include: :line_items)
    @q = CarPart.search(params[:q])
  end
  
  def cancel
    @entry = Entry.find(params[:id], include: :line_items)
    @line_items = @entry.line_items.includes(:car_part, :bids, :order).order('status DESC')
  end
  
  def add_specs
    @entry = Entry.find(params[:id], include: :line_items)
    @line_items = @entry.line_items.includes(:car_part).order('status DESC')
  end
  
  def save_specs
    # raise params.to_yaml
    @entry = Entry.find(params[:id], include: :line_items)
    @line_items = LineItem.find(params[:items].map { |k,v| k.to_i })
    @line_items.each do |li|
      li.update_attribute(:specs, params[:items].fetch(li.id.to_s)[0])
    end
    respond_to do |format|
      if can? :access, :all
       format.html { redirect_to @entry }
      else
       format.html { redirect_to buyer_show_path(@entry) }
      end
      format.js { render action: :cancel }
    end
  end
end
