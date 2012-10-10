class VarItem < ActiveRecord::Base
  attr_accessible :variance_id, :line_item_id, :qty, :var_base, :discount, :var_amt, 
  :var_total, :var_type, :bid_id, :amount, :total, :bid_type, :seller_company_id, :var_net

  belongs_to :variance
  belongs_to :seller_company, class_name: "Company", foreign_key: "seller_company_id"
  belongs_to :line_item
  belongs_to :bid

  def populate(discount)
    self.discount = discount
    if self.var_base.present?
      self.var_amt =  self.var_base.to_f * (1 - (discount.to_f/100))
      self.var_total =  self.qty * self.var_amt
      comparative_bid = Bid.where(line_item_id: self.line_item_id, bid_type: self.var_type).last
      if comparative_bid.present?
        self.save_values(comparative_bid)
        self.var_net = self.var_total - self.total
      else
        lowest_bid = Bid.where(line_item_id: self.line_item_id).last
        if lowest_bid.present?
          self.save_values(lowest_bid)
        end
      end
    else
      lowest_bid = Bid.where(line_item_id: self.line_item_id).last
      if lowest_bid.present?
        self.save_values(lowest_bid)
      end
    end
  end
  
  def save_values(bid)
    self.bid_id = bid.id
    self.amount = bid.amount
    if self.qty == bid.quantity
      self.total = bid.total
    else
      self.total = self.qty * bid.amount
    end
    self.bid_type = bid.bid_type
    self.seller_company_id = bid.user.company.id
  end
end
