module MessagesHelper
  def msg_index_link
    if can? :access, :all
      messages_path
    elsif can? :access, :buyer
      buyer_messages_path
    elsif can? :access, :seller
      seller_messages_path 
    end
  end
  
  def nested_messages(messages, klass=nil)
    messages.map do |message, sub_messages|
      (render message) + (nested_messages(sub_messages) if sub_messages.present?)
    end.join.html_safe
  end
  
  def msg_sender_helper(message, current_user)
    if message.user_company_id == current_user.company.id
      case message.user_id
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
      when current_user.id then content_tag :span, 'YOU', class: 'label label-info'
      else content_tag :span, message.user.fullname, class: 'small'
      end
    else
      case message.user_id
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
      when nil then nil
      else 
        if message.order_id.present?
          content_tag :em, message.user_company.nickname, class: 'small'
        else 
          "#{message.user_type} ##{message.user_id}".upcase
        end
      end
    end
  end
  
  def msg_receiver_helper(message, current_user)
    if message.receiver_company_id == current_user.company.id
      case message.receiver
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
      when current_user then content_tag :span, 'YOU', class: 'label label-info'
      else content_tag :span, message.receiver.fullname, class: 'small'
      end
    else
      case message.receiver_id
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
      when nil then nil
      else 
        if message.order_id.present?
          (content_tag :em, message.receiver_company.nickname, class: 'small')
        else 
          "#{message.receiver.roles.first.name} ##{message.receiver_id}"
        end
      end
    end
  end
  
  def msg_for_helper(f, entry, order = nil)
    case order.present?
    when true
      if can?(:access, :all) || can?(:access, :buyer)
        collection = ['Admin', 'Buyer', 'Seller']
      else
        collection = ['Admin', 'Buyer']
      end
      checked = 'Buyer'
    else
      if entry.user != current_user
        collection = ['Admin', 'Buyer']
        checked = 'Buyer'
      else
        collection = ['Admin']
        checked = 'Admin'
      end
    end
    f.input :msg_for, as: :radio_buttons, collection: collection, checked: checked, label: 'Message For', item_wrapper_class: 'inline'
  end
end
