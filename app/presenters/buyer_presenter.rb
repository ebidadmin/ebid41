class BuyerPresenter
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  include ActionView::Helpers::TextHelper 

  def initialize(user)
    @user = user
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
end