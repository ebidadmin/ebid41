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
      when current_user.id then content_tag :span, 'YOU', class: 'label'
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
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
          "#{message.user_type} ##{message.user_id}"
        end
      end
    end
  end
  
  def msg_receiver_helper(message, current_user)
    if message.receiver_company_id == current_user.company.id
      case message.receiver
      when current_user then content_tag :span, 'YOU', class: 'label'
      when 1 then content_tag :span, 'ADMIN', class: 'label label-important'
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
  
  # def user_signature(message, current_user)
  #    sender = case message.user
  #    when current_user then content_tag :span, 'YOU said', class: 'label label-info'
  #    else 
  #      if message.user.id == 1
  #        "ADMIN said"
  #      else
  #        "#{message.user_type.titleize} ##{message.user_id} said"
  #      end
  #    end
  # 
  #    receiver = case message.receiver
  #    when nil then nil
  #    when current_user then content_tag :span, 'to YOU', class: 'label'
  #    else 
  #      if message.receiver.roles.present?
  #        "to #{message.receiver.roles.first.name}"
  #      end
  #    end
  # 
  #    "#{sender} #{receiver if receiver.present?}".html_safe
  #  end
end
