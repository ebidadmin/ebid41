class Message < ActiveRecord::Base
  include ActionView::Helpers
  
  attr_accessible :user_id, :user_type, :alias, :user_company_id, :receiver_id, :receiver_company_id, 
  :entry_id, :order_id, :message, :open_tag, :ancestry, :parent_id, :msg_for, :read_on
  
  attr_accessor :msg_for
  
  has_ancestry
  
  before_save :strip_blanks
  
  belongs_to :entry
  belongs_to :order
  belongs_to :user
  belongs_to :receiver, :class_name => "User", :foreign_key => "receiver_id"
  belongs_to :user_company, :class_name => "Company", :foreign_key => "user_company_id"
  belongs_to :receiver_company, :class_name => "Company", :foreign_key => "receiver_company_id"

  # default_scope includes([:user => :company], [:receiver => :company]).order('created_at DESC')
  default_scope includes(:user, :receiver)
  scope :pub, where(open_tag: true)
  scope :pvt, where(open_tag: false)
  scope :unread, where(read_on: nil)
  
  validates_presence_of :message

  def self.restricted(company)
    where('user_company_id = ? OR receiver_company_id = ?', company, company)
  end
  
  def self.this_user(user)
    where('user_id = ? OR receiver_id = ?', user, user)
  end

  def for_cancelled_order(current_user, msg_sender, order, cancelled_bids, reason)
    case msg_sender
    when 'admin', 'buyer'
      self.user_company_id = order.company_id
      self.receiver_id = order.seller_id
      self.receiver_company_id = order.seller_company_id
    when 'seller' 
      self.user_company_id = order.seller_company_id
      self.receiver_id = order.user_id
      self.receiver_company_id = order.company_id
    end
    
    if order.bids.all?(&:cancelled?)
      # "ENTIRE ORDER cancelled."
      self.message = "ENTIRE ORDER cancelled by #{msg_sender.titleize} *** #{cancelled_bids.collect { |b| b.line_item}.to_sentence} *** REASON: #{reason.strip.capitalize}"
      order.update_attributes(status: "Cancelled", cancelled: Date.today, order_total: order.bids.collect(&:total).sum)
    else
      # "PARTIAL ORDER cancelled."
      self.message = "PARTIAL ORDER cancelled by #{msg_sender.titleize} *** #{cancelled_bids.collect { |b| b.line_item}.to_sentence} *** REASON: #{reason.strip.capitalize}"
      order.update_attribute(:order_total, order.order_total - cancelled_bids.collect(&:total).sum) unless order.order_total == 0
    end
    order.messages << self
    Notify.delay.cancelled_order(order, self)#.deliver
  end
  
  def self.for_additional_parts(entry, line_items)
    m = self.new(
      user_id: entry.user_id, user_company_id: entry.company_id, user_type: entry.user.roles.first.name,
      entry_id: entry.id, read_on: Time.now
      )
    m.message = "#{entry.status.upcase} (#{line_items.count}): #{line_items.map(&:car_part).to_sentence} (online # #{entry.relist_count + 1})"
    m.save!
  end

  def self.for_rebidding(user, entry)
    m = user.messages.build(
      user_company_id: user.company.id, user_type: user.roles.first.name,
      entry_id: entry.id, read_on: Time.now
      )
    m.message = "#{entry.status.upcase}: #{entry.relisted.to_s(:long)} (online # #{entry.relist_count + 1}) | #{user}"
    m.save!
  end
  
  private
  
  def strip_blanks
    self.message.strip
  end
  
end
