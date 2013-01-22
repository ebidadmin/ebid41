class RatingsController < ApplicationController
  include ActionView::Helpers::TextHelper 

  def index
    if can? :access, :all
      @ratings = Rating.order('id DESC').includes(:order, :user => :company, :ratee => :company).paginate(page: params[:page], per_page: 30)
    else
      if params[:user_id] == 'all'
        @ratings = Rating.where(ratee_id: current_user.company.users).order('id DESC').paginate(page: params[:page], per_page: 30)
      else
        @ratings = Rating.where(ratee_id: current_user).order('id DESC').paginate(page: params[:page], per_page: 30)
      end
    end
  end

  def show
    @rating = Rating.find(params[:id])
  end

  def new
    @rating = Rating.new
  end

  def create
    @rating = Rating.new(params[:rating])
    if @rating.save
      redirect_to @rating, :notice => "Successfully created rating."
    else
      render :action => 'new'
    end
  end

  def edit
    @rating = Rating.find(params[:id])
  end

  def update
    @rating = Rating.find(params[:id])
    if @rating.update_attributes(params[:rating])
      redirect_to @rating, :notice  => "Successfully updated rating."
    else
      render :action => 'edit'
    end
  end

  def destroy
    @rating = Rating.find(params[:id])
    @rating.destroy
    redirect_to ratings_url, :notice => "Successfully destroyed rating."
  end
  
  def auto
      @orders = Order.unscoped.where(status: ['Paid', 'Closed']).payment_valid.includes(:company => :users, :ratings => [:user, :ratee])#.limit(5)#.joins(:ratings)
      @orders.each do |order|
        ratings = Array.new
        if order.ratings.where(user_id: order.company.users).blank?
          rating = Rating.seller_rating(order)
          rating.review = "Delivered #{pluralize order.delivery_time, 'day'} from acceptance of PO." 
          ratings << rating
        end
        if order.ratings.where(ratee_id: order.company.users).blank?
          rating = Rating.buyer_rating(order)
          rating.review = case order.prompt_payment?
          when 0..30 then "Paid #{pluralize order.paid_before_due_date, 'day'} BEFORE DUE DATE. Thanks and keep it up!"
          else "Paid #{pluralize order.paid_but_overdue, 'day'} OVERDUE." 
          end
          ratings << rating
        end
        order.ratings << ratings
        if order.ratings.where(:user_id => order.company.users).exists? && order.ratings.where(:ratee_id => order.company.users).exists?
          order.close
        end
      end
      
      flash[:notice] = "Successfully created auto ratings."  
      redirect_to :back
  end
end
