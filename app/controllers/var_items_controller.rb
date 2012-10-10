class VarItemsController < ApplicationController
  def index
    @var_items = VarItem.all
  end

  def show
    @var_item = VarItem.find(params[:id])
  end

  def new
    @var_item = VarItem.new
  end

  def create
    @var_item = VarItem.new(params[:var_item])
    if @var_item.save
      redirect_to @var_item, :notice => "Successfully created var item."
    else
      render :action => 'new'
    end
  end

  def edit
    @var_item = VarItem.find(params[:id])
  end

  def update
    @var_item = VarItem.find(params[:id])
    if @var_item.update_attributes(params[:var_item])
      redirect_to @var_item, :notice  => "Successfully updated var item."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @var_item = VarItem.find(params[:id])
    @var_item.destroy
    redirect_to var_items_url, :notice => "Successfully destroyed var item."
  end
end
