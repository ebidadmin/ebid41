module BidsHelper
  def th_bidtype_helper(bidtype)
    desc = case bidtype
    when 'Original' then 'OEM (Brand New)'
    when 'Replacement' then 'Third Party (Brand New)'
    when 'Surplus' then 'USED'
    end
    
    content_tag :th, content_tag(:span, "#{bidtype.upcase}<br>#{content_tag :span, desc, class: 'badge badge-important'}".html_safe), class: 'span2 txtcenter'
  end
  
  def bid_box_helper(item_id, category)
    text_field_tag("bids[#{item_id}][#{category}]", nil, class: 'input-small')
  end
  
  def bid_amount_helper(bid, f=nil)
    content_tag :p, class: "#{bid.status_color}" do
      amount = content_tag :span, currency(bid.amount), class: 'bid-amount'
      editable_amount = content_tag :span, link_to(currency(bid.amount), edit_bid_path(bid)), class: 'bid-amount'
      display_name = content_tag :em, bid.user.username, class: 'small'

      if can? :access, :all
        editable_amount + display_name
      elsif f.present?
        (f.radio_button 'id', bid.id) + amount + display_name
      else
        amount + display_name
      end
    end 
  end
  
  def bid_quantity_helper(bid, action) # used in bids/accept
     if action == 'show' || action == 'cancel'
       bid.quantity
     elsif bid.cancelled?
       nil
     else
       text_field_tag "bids[#{bid.id}][]", bid.quantity, class: 'input-mini txtcenter'
     end
   end
  
   def check_box_helper(bid, order, user, action)
     if (action == 'cancel' || action == 'show') && order.can_be_cancelled(user)
       bid.cancelled? ? nil : check_box_tag('bid_ids[]', bid.id, true)
     end
   end
  
   def total_label_helper(order, bids=nil, action=nil)
     case action
     when 'cancel' then "For Cancellation (#{pluralize bids.count, 'part'})"
     when 'accept' then "Total (#{pluralize bids.count, 'part'})"
     else "Total (#{pluralize order.bids.not_cancelled.count, 'part'})"
     end
   end

   def total_amount_helper(order, bids=nil, action=nil)
     case action
     when 'cancel', 'accept' then currency(bids.collect(&:total).sum, 'P ')
     else currency(order.bids.not_cancelled.collect(&:total).sum, 'P ')
     end
   end

  
end
