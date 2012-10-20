class CartController < ApplicationController
  include ActionView::Helpers::TagHelper
  before_filter :initialize_cart

  def add
    @entry = Entry.find(params[:id])
    @item = @cart.add(params[:part])
  end

  def remove
  end

  def clear
    @entry = Entry.find(params[:id])
    @line_items = @entry.line_items
    @cart.cart_items.destroy_all
    render 'add'
  end
end
