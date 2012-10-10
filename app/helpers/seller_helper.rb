module SellerHelper
  def supplier_bid_rate(entry, bids)
    if bids.present?
  	  "You bidded #{bids.collect(&:line_item_id).uniq.count} of #{pluralize entry.line_items.size, 'part'}"
	  else
	    content_tag :span, "You have no bids", class: 'highlight'
    end
  end
end
