class BuyerPresenter
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper 

  def initialize(user)
    @user = user
  end
  
  def company_rating
    Rating.where(ratee_id: @user.company.users)
  end
  
  def user_rating
    Rating.where(ratee_id: @user.id)
  end
  
  def draft_entries
    if @user.has_role? :powerbuyer
      @drafts ||= Entry.where(status: ['New', 'Edited'], company_id: @user.company.id)
    else
      @drafts ||= @user.entries.where(status: ['New', 'Edited'])
    end
  end
  
  def online_entries
    if @user.has_role? :powerbuyer
      @online  ||= Entry.online.unexpired.where(company_id: @user.company.id)
    else
      @online ||= @user.entries.online.unexpired
    end
  end
  
  def for_decision_entries
    if @user.has_role? :powerbuyer
      @fd ||= Entry.for_decision.unexpired.where(company_id: @user.company.id)
    else
      @fd ||= @user.entries.for_decision.unexpired
    end
  end
  
  def with_orders_entries
    if @user.has_role? :powerbuyer
      @wo ||= Entry.with_orders.where(company_id: @user.company.id)
    else
      @wo ||= @user.entries.with_orders
    end
  end
  
  def declined_entries
    if @user.has_role? :powerbuyer
      @dec ||= Entry.declined.where(company_id: @user.company.id)
    else
      @dec ||= @user.entries.declined
    end
  end
  
  def order_ratio
    percentage @user.company.perf_ratio, 1
  end
  
  def order_ratio_details
    entries = @user.company.entries.where('created_at >= ?', Company::RATIO_DATE)
    items ||= LineItem.with_bids.where(entry_id: entries)
    orders = items.where('order_id IS NOT NULL')
    # orders = @user.company.orders.collect(&:bids)
    
    @details = "#{orders.count} out of #{pluralize items.count, 'part'}"
  end
  
  def orders
    @user_orders ||= Order.by_this_buyer(@user)
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
  
  def average_payment_time
    o ||= Order.where(company_id: @user.company.id, status: ['Paid', 'Closed']).where('paid IS NOT NULL')
    @average = o.collect(&:prompt_payment?).sum/o.count if o.present?
  end
  
end