class SellerPresenter
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper 

  def initialize(user)
    @user = user
  end
  
  def company_rating
    Rating.where(ratee_id: @user.company.users)
  end
  
  def average_delivery_time
    orders ||= Order.where(seller_company_id: @user.company.id, status: ['Paid', 'Closed'])
    @average = orders.collect(&:delivery_time).sum/orders.count if orders.present?
  end
  
  def online_entries
    @online ||= Entry.online.unexpired.active.joins{company.friends}.where(:friendships => { :friend_id => @user.company.id})
  end
  
  def for_decision_entries
    @fd ||= Entry.for_decision.unexpired.joins{company.friends}.where(:friendships => { :friend_id => @user.company.id})
  end
  
  def bidding_ratio
    percentage @user.company.perf_ratio, 1
  end
  
  def bidding_ratio_details
    bids = @user.company.users.map{|user| user.bids.where('bids.created_at >= ?', Company::RATIO_DATE).collect(&:line_item_id).uniq.count}.sum
    items = LineItem.where('line_items.created_at >= ?', Company::RATIO_DATE)
 
    @details = "#{bids} out of #{pluralize items.count, 'part'}"
  end
  
  def orders
    @user_orders ||= Order.by_this_seller(@user.company)
  end
  
  def new_orders
    @new_orders ||= orders.where(status: ['New PO', 'PO Released'])
  end
  
  def delivered
    @delivered ||= orders.delivered.where('orders.due_date >= ?', Date.today)
  end
  
  def overdue
    @overdue ||= orders.overdue
  end
  
  def total_orders
    @total ||= orders.not_cancelled.sum(:order_total)
  end
  
end