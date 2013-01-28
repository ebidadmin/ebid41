class AdminPresenter
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper 

  def initialize(user)
    @user = user
  end
  
  def average_delivery_time
    orders ||= Order.where(status: ['Paid', 'Closed'])
    @average = orders.collect(&:delivery_time).sum/orders.count if orders.present?
  end
  
  def draft_entries
    @drafts ||= Entry.where(status: ['New', 'Edited'])
  end
  
  def online_entries
    @online ||= Entry.online.unexpired
  end
  
  def for_decision_entries
    @fd ||= Entry.for_decision.unexpired
  end
  
  def with_orders_entries
    @wo ||= Entry.with_orders
  end
  
  def declined_entries
    @dec ||= Entry.declined
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
    @user_orders ||= Order.scoped
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
  
  def orders_this_yr
    @ody ||= orders.not_cancelled.where('created_at >= ?', Time.now.beginning_of_year).sum(:order_total)
  end
  
  def active_users
    User.where('current_sign_in_at >= ?', Date.today.beginning_of_day)
  end
end