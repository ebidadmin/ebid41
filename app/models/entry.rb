class Entry < ActiveRecord::Base
  attr_accessible :bid_until, :bids_count, :car_brand_id, :car_model_id, :car_variant_id, :chargeable_expiry, :city_id, :company_id, 
  :date_of_loss, :decided, :expired, :line_items_count, :motor_no, :online, :bid_until, :orders_count, :photos_count, :plate_no, :redecided, :ref_no, 
  :relist_count, :relisted, :serial_no, :status, :term_id, :user_id, :year_model, :photos_attributes, :photo
  
  before_save :convert_numbers
  
  belongs_to :user, counter_cache: true
  belongs_to :company
  belongs_to :car_brand
  belongs_to :car_model
  belongs_to :car_variant
  belongs_to :city
  belongs_to :term
  
  has_many :photos, dependent: :destroy
  accepts_nested_attributes_for :photos, allow_destroy: true, :reject_if => proc { |a| a['photo'].blank? }
  has_many :line_items, dependent: :destroy
  has_many :car_parts, through: :line_items
  has_many :bids
  has_many :orders, validate: true
  accepts_nested_attributes_for :orders, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_many :messages, dependent: :destroy
  has_many :fees
  
  has_one :variance, dependent: :destroy
  
  validates_presence_of :year_model, :car_brand_id, :car_model_id, 
  :plate_no, :serial_no, :motor_no, :term_id

  default_scope order('updated_at DESC', 'status ASC')
  scope :active, where('entries.bid_until >= ?', Date.today)
  scope :unexpired, where(:expired => nil)
  scope :online, where(status: ['Online', 'Relisted', 'Additional', 'Re-bidding']).order('bid_until DESC')
  scope :for_decision, where(status: ['For-Decision', 'Ordered-IP', 'Declined-IP'])
  scope :with_orders, where('entries.status LIKE ?', "%Ordered%") 
  scope :declined, where(status: ['Declined-IP', 'Declined-All'])
  scope :for_seller, where{(status.not_like '%New%') & (status.not_like '%Edited%') & (status.not_like '%Removed%')} #where('entries.status NOT LIKE ?', ['New', 'Edited', 'Removed'])
  
  YEAR_MODELS = (30.years.ago.year .. Date.today.year).to_a.reverse
  TAGS_FOR_SIDEBAR = %w(created online decided relisted redecided bid_until expired)
  STATUS_TAGS = %w(New Online Additional Relisted For-Decision Ordered-IP Ordered-All Ordered-Declined Declined-IP Declined-All) 
  MIN_BIDDING_TIME = 0#3.hours #5.minutes
 
  # DEFINITIONS
  def model_name
    "#{year_model} #{car_brand.name if car_brand} #{car_model.name if car_model}".html_safe 
  end
  
  def variant
    car_variant.name.html_safe if car_variant.present?
  end
  
  # ACTIONS
  def self.find_status(status, buyer = nil)
    case status
    when 'new' then where(status: ['New', 'Edited'])
    when 'online'
      if buyer == true
        online.unexpired #.active
      else
        online.active.unexpired#unscoped.online.order('bid_until DESC', 'status ASC')
      end
    when 'for-decision' then for_decision.unexpired.order('decided DESC')
    when 'ordered' then with_orders
    when 'declined' then declined.order('expired DESC', 'created_at DESC')
    when 'expired' then unscoped.with_orders.where('expired >= ?', Date.today.beginning_of_month).order('expired DESC', 'created_at DESC')
    when 'all' then scoped.for_seller
    else scoped.for_seller
    end
  end
  
  def self.by_this_buyer(user)
    if user.has_role? :powerbuyer
      where(company_id: user.company)
    else
      where(user_id: user)
    end
  end

  def add_line_items_from_cart(cart)
		cart.cart_items.each do |item|
			li = LineItem.from_cart_item(item)
			if line_items.present? && status != 'New'
			  li.status = 'Additional'
		  else
			  li.status = 'Online'
		  end
      line_items.new_items.update_all(status: 'Online')
			line_items << li 
		end
    cart.cart_items.destroy_all
    if line_items.additional.present?
      update_attributes(status: 'Additional', bid_until: 1.week.from_now, relisted: Time.now, relist_count: self.relist_count += 1, chargeable_expiry: nil, expired: nil)
      Message.for_additional_parts(self, line_items.additional)
    else
      update_attributes(status: "Online", online: Time.now, bid_until: 1.week.from_now)
    end
    send_online_mailer
  end  
  
	def put_online
	  if self.update_attributes(status: "Online", online: Time.now, bid_until: 1.week.from_now)
      line_items.update_all(:status => "Online")
      bids.update_all(:status => 'New') if bids.present?
    end
    send_online_mailer
	end

  def send_online_mailer
    self.company.friends.includes(:users => :profile).each do |friend|
      if friend.users.enabled.opt_in.present?
        sellers = friend.users.enabled.opt_in.includes(:profile).collect { |u| "#{u.profile} <#{u.email}>" }
        Notify.delay.online_entry(sellers, self)#.deliver 
      end
    end
  end

  def reveal
    if self.update_attributes(status: "For-Decision", decided: Time.now, expired: nil)
      line_items.includes(:bids, :order).each { |item| item.update_for_decision if item.order.blank? }
      flash = "Bidding is now finished. Bids are revealed below. You can proceed to Create PO.".html_safe
    end
  end

  def reveal2
    if self.update_attributes(status: "For-Decision", redecided: Time.now)
      line_items.includes(:bids, :order).each { |item| item.update_for_decision if item.order.blank? }
      flash = "Bidding is now finished. Bids are revealed below. You can proceed to Create PO.".html_safe
    end
  end

	def rebid
    if self.update_attributes(status: 'Re-bidding', bid_until: 3.days.from_now, relisted: Time.now, relist_count: self.relist_count += 1, chargeable_expiry: nil, expired: nil)
      # line_items.update_all(status: 'Re-bidding', relisted: Time.now) 
      # bids.not_cancelled.without_orders.update_all(status: 'Re-bidding') if bids.present?
      line_items.each do |item|
        item.update_attributes(status: 'Re-bidding', relisted: Time.now) if item.order.blank? # don't rebid if PO
        item.bids.not_cancelled.without_orders.update_all(status: 'Re-bidding') if item.bids.present?
      end
      send_online_mailer
      flash = "Entry is now online for re-bidding."
	  end
	end

  def update_status
    items_with_bids = line_items.with_bids.count
	  unless orders.blank?
      if items_with_bids == bids.with_orders.count
        update_attribute(:status, "Ordered-All")
      elsif items_with_bids == bids.with_orders.count + line_items.declined.count
        update_attribute(:status, "Ordered-Declined")
      else
        update_attribute(:status, "Ordered-IP")
      end
	  else
  	  declined_count = line_items.declined.count
      if items_with_bids == declined_count
        update_attribute(:status, "Declined-All")
      else
        update_attribute(:status, "Declined-IP")
      end
	  end
	end
	
	# STATUS INDICATORS
  def newly_created? 
    status == 'New' || status == 'Edited'
  end
  
  def is_online
	  status == 'Online' || status == 'Additional' || status == 'Relisted' || status == 'Re-bidding' 
	end
	
	def can_reveal
    if relisted.present?
      ready_for_reveal = Time.now > relisted + MIN_BIDDING_TIME
    elsif online.present?
      ready_for_reveal = Time.now > online + MIN_BIDDING_TIME
    end
    ready_for_reveal && (bids.present? && bids.online.present?)
	end

  def can_reactivate
    # expired && updated_at > 1.month.ago && line_items.collect(&:status).uniq.include?("Expired")
   updated_at > 1.month.ago && line_items.collect(&:status).uniq.include?("Expired")
  end

  def can_be_ordered
    line_items.present? && line_items.collect(&:status).uniq.include?("For-Decision")
  end
  
  def can_reactivate
   line_items.collect(&:status).uniq.include?("Expired")
  end
  
  def has_order
    orders_count > 0
  end

  def needs_stock_warning?
    if relisted
      relisted <= 3.days.ago
    else
      online <= 3.days.ago
    end
  end
  
  def online_or_relisted?
    if relisted
      relisted
    else
      online
    end
  end
  
  # 
	def unique_bidders
    bids.collect(&:user_id).uniq.count
  end
  
  def items_bidded
    bids.collect(&:line_item_id).uniq.count
  end
  
  def bid_rate_overview # in buyer#entries
    (items_bidded.to_f/line_items.size.to_f) * 100
  end

  def bid_rate_by_supplier(current_user) # in seller#entries
    (bids.by_user(current_user.company.users).collect(&:line_item_id).uniq.count.to_f/line_items.size.to_f) * 100
  end

  def show_status
    if expired.nil?
      "#{status}"
    else
      "#{status} (Expired)".html_safe
    end
  end
  
  def status_date
    case status
    when 'New' then created_at
    when 'Online' then online
    when 'Additional', 'Relisted', 'Re-bidding' then relisted
    # when 'For-Decision' then decided
    else updated_at
    end
  end
  
  def status_color
    case status
    when 'Online', 'Additional', 'Relisted', 'Re-bidding' then 'label-info'
    when 'For-Decision' then 'label-highlight'
    when 'Ordered-Declined', 'Ordered-IP', 'Ordered-All' then 'label-success'
    when 'Declined-IP', 'Declined-All', 'Re-bidding' then 'label-warning'
    else nil
    end
  end
	
	private
	
	def convert_numbers
    self.ref_no.upcase! if self.ref_no.present?
    self.plate_no.upcase!
    self.motor_no.upcase!
    self.serial_no.upcase!
    # %w(self.ref_no, self.plate_no, self.motor_no, self.serial_no).each { |n| n.strip.upcase! if n }
	end
	
	
end
