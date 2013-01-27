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
    mail to: "#{order.user.profile} <#{order.user.email}>", subject: "Delivered: #{entry.model_name}", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end
  
  def payment_tagged(order, entry)
    @order = order
    @entry = entry
    mail to: "#{order.seller.profile} <#{order.seller.email}>", subject: "PO Tagged as 'Paid':  #{currency order.order_total, 'P '}"
  end

  def overdue_payment(powerbuyers, company, orders)
    @orders = orders
    @company_name = company
    mail to: powerbuyers, subject: "OVERDUE PAYMENT Reminder: #{currency(@orders.collect(&:order_total).sum, 'P ')} (from #{regular_date Time.now.beginning_of_week} to #{regular_date Time.now.end_of_week})", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end

  def due_now(powerbuyers, company, orders)
    @orders = orders
    @company_name = company
    mail to: powerbuyers, subject: "DUE NOW Reminder: #{currency(@orders.collect(&:order_total).sum, 'P ')} (from #{regular_date Time.now.beginning_of_week} to #{regular_date Time.now.end_of_week})", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end
  
  def deliver_now(sellers, company, orders)
    @orders = orders
    @company_name = company
    mail to: sellers, subject: "LATE DELIVERY Reminder: #{currency(@orders.collect(&:order_total).sum, 'P ')} (from #{regular_date Time.now.beginning_of_week} to #{regular_date Time.now.end_of_week})", 
      bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end
  
  def new_message(entry, message)
    @entry = entry
    @message = message
    mail to: "#{message.receiver.profile} <#{message.receiver.email}>", 
      subject: "You have a PM for #{entry.model_name}"
  end

  def cancelled_order(order, message)
    @order = order
    @message = message
    mail to: ["#{order.user.profile} <#{order.user.email}>", "#{order.seller.profile} <#{order.seller.email}>"],
      subject: "Order CANCELLED: #{currency(@order.order_total, 'P ')}", bcc: "Efren Magtibay <epmagtibay@ebid.com.ph>"
  end

  
end
