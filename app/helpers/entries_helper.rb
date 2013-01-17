module EntriesHelper
  def link_to_entry_helper(entry, text = "Review Entry/Photos", klass = nil)
    if can? :access, :all
      path = entry 
    elsif can? :create, :entries                                                       
      path = buyer_show_path(entry) 
    else      
      path = seller_show_path(entry)                                                                      
    end

    link_with_icon text, path, 'folder-open', "btn-primary #{klass if klass}", true 
  end

	def get_date_for_sidebar(entry, tag)
    date = case tag
	  when 'created' then regular_date entry.created_at, 'short_daytime'
    when 'expired', 'bid_until' then regular_date entry.send(tag.downcase), 'day' if entry.send(tag.downcase)
	  else regular_date entry.send(tag.downcase), 'short_daytime' if entry.send(tag.downcase).present?
	  end

    caption = case tag
    when 'bid_until'
      if entry.bid_until && Time.now < entry.bid_until then 'Bidding Deadline'
      else 'Bidding Ended'
      end
    else tag
    end
    
    content_tag :li do
      (content_tag :b, caption.upcase) + ' ' + date + (content_tag :span, '|', class: 'divider' unless tag == 'expired')
    end if date
	end
	
  # def bidding_session_time_helper(entry, klass=nil)
  #   if entry.is_online 
  #     if Time.now < entry.bid_until
  #       dl_helper 'Bidding Deadline', long_date(entry.bid_until), klass
  #     else
  #       dl_helper 'Bidding Session Ended', long_date(entry.bid_until), klass
  #     end
  #   end
  # end
  
  def number_of_bidders(entry)
    if entry.newly_created?
      content_tag :span, "Entry is still OFFLINE", class: 'muted'
    else
      count = entry.unique_bidders
      if count > 0
        content_tag :b, (pluralize count, 'bidder')
      else
        content_tag :b, "Sorry, no bidders", class: 'muted'
      end
    end
  end
  
  def parts_bidded(entry, supplier)
    if entry.bid_rate_by_supplier(supplier) > 0
      color = case entry.bid_rate_by_supplier(supplier)
      when 100 then ' badge-success'
      else ' badge-warning'
      end
      content_tag :span, "#{percentage(entry.bid_rate_by_supplier(current_user), 0)} bidded", class: "badge#{color}" 
    else
      content_tag :span, 'You have no bids', class: 'badge badge-important'
    end
  end
  
  def fastest_bid(entry)
    "Speed: #{time_in_words entry.bids.minimum(:bid_speed)}"
  end
  
  def entry_status_helper(entry, klass=nil)
    content_tag :span, class: "label #{entry.status_color} #{klass}" do
      "#{entry.show_status}#{'<br> (with cancellation)' if !entry.is_online && entry.bids.cancelled.present? }".html_safe
    end
  end
  
  def order_now_helper(entry)
    if (entry.status == "For-Decision" || entry.status == "Ordered-IP" || entry.status == "Declined-IP") && entry.expired.nil?
      deadline = entry.bid_until + 3.days
      if Time.now < deadline 
        content_tag(:span, "Order Now!", class: 'label label-important') +
        content_tag(:p, "Expiry: #{time_ago_in_words(deadline)}")
      elsif Time.now == deadline
        content_tag(:span, "Order Now!", class: 'label label-important') +
        content_tag(:p, "Expiring Today")
      elsif Time.now > deadline
        content_tag(:span, "Lapsed", class: 'label') +
        content_tag(:p, regular_date(deadline), class: 'muted')
      end
    end
  end
  
  def progress_bar_helper(bar_size)
    if bar_size && bar_size == '100.00%'
      bar = 'progress-success'
    else
      bar = 'progress-warning'
    end
    
    content_tag :div, class: "progress #{bar} progress-striped active" do
      content_tag :div, '', class: 'bar', style: "width: #{bar_size}"
    end
  end
  
  def message_count_helper
    if can? :access, :all
      pluralize(@entry.messages.pvt.size, "message")
    else
      pluralize(@entry.messages.pvt.restricted(current_user.company).size, "message")
    end
  end
end
