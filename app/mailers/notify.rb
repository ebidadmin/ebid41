class Notify < ActionMailer::Base
  default from: "no_reply@ebid.com.ph"
  helper :application
  include ActionView::Helpers::NumberHelper
  include ApplicationHelper
    
  def online_entry(sellers, entry)
    @entry = entry
    mail to: sellers, subject: "#{entry.status.upcase}: #{entry.model_name}"
  end
  
  def new_order(order)
    @order = order
    mail to: "#{order.seller.profile} <#{order.seller.email}>", subject: "New PO: #{currency order.order_total, 'P '}", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end
  
  def delivered(order, entry)
    @order = order
    @entry = entry
    mail to: "#{entry.user.profile} <#{entry.user.email}>", subject: "Delivered: #{entry.model_name}", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end
  
  def payment_tagged(order, entry)
    @order = order
    @entry = entry
    mail to: "#{order.seller.profile} <#{order.seller.email}>", subject: "PO Tagged as 'Paid':  #{currency order.order_total, 'P '}"
  end
  
end
