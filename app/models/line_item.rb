class LineItem < ActiveRecord::Base
  attr_accessible :entry_id, :car_part_id, :specs, :quantity, :status, :bids_count, :relisted, :order_id

  belongs_to :car_part
  belongs_to :entry, counter_cache: true
  belongs_to :order

  has_many :bids, dependent: :destroy
  has_many :fees
  has_one :var_item#, dependent: :destroy

  STATUS_TAGS = ['New', 'Online', 'Additional', 'Relisted', 'Re-bidding', 'For-Decision',
    'New PO', 'For-Delivery', 'Delivered', 'Paid.', 'Paid', 'Closed', 'Lose', 'Cancelled']

  scope :new_items, where(status: 'New')
  scope :additional, where(status: 'Additional')
  scope :online, where(status: ['Online', 'Relisted', 'Additional', 'Re-bidding'])
  scope :declined, where(status: ['Declined', 'Expired'])
  scope :with_bids, where('line_items.bids_count > 0')
  scope :without_bids, where('line_items.bids_count < 1')
  scope :not_cancelled, where('line_items.status NOT LIKE ?', "%Cancelled%") 

  def to_s
    car_part.name.html_safe
  end
  
  def custom_method
    case status
    when 'Online', 'Additional', 'Relisted', 'Re-bidding' then 0
    when 'For-Decision' then 1
    when 'New PO', 'PO Released', 'For-Delivery', 'Delivered', 'Paid.', 'Paid', 'Closed' then 2
    when 'Expired', 'Declined' then 3
    when 'Cancelled by admin', 'Cancelled by buyer', 'Cancelled by seller', 'Cancelled' then 4
    else 5
    end
  end

  # Actions
	def self.from_cart_item(cart_item)
		li = self.new
		li.car_part_id = cart_item.car_part_id
		li 
	end 

	def update_for_decision
	  if bids.present?
      update_attribute(:status, "For-Decision")
      bids.update_for_decision
	  else
      update_attribute(:status, "No Bids") 
	  end 
	end
	
	def expire
    if bids.present? #WITH BIDS
      lowest_bid = bids.for_decision.not_cancelled.last
      lowest_bid.expire if lowest_bid
      self.update_attribute(:status, "Expired")
    else #WITHOUT BIDS
      update_attribute(:status, "No Bids")
    end
	end
	
	# Status indicators
	def is_online
	  status == 'Online' || status == 'Relisted' || status == 'Additional' || status == 'Re-bidding'
	end

	def can_be_ordered
    status == "For-Decision" || status == "Expired" || self.cancelled
  end
  
  def cannot_be_expired
    self.order_id.present? || self.declined_or_expired || self.cancelled
  end
  
  def declined_or_expired 
    status == "Declined" || status == "Expired"
  end
  
  def cancelled
    status.include?('Cancelled')
  end
  

  def status_color
    case status
    when 'Online', 'Additional', 'Relisted', 'Re-bidding' then 'label-info'
    when 'For-Decision' then 'highlight'
    when 'New PO', 'PO Released', 'For-Delivery', 'Delivered', 'Paid!', 'Paid', 'Closed' then 'label-success'
    when 'Expired', 'Declined' then 'label-warning'
    when 'Cancelled by admin', 'Cancelled by buyer', 'Cancelled by seller', 'Cancelled' then 'label-black'
    else nil
    end
    # 'black' if status.include?('Cancelled')
  end
	
end
