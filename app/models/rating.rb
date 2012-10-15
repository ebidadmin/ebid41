class Rating < ActiveRecord::Base

  attr_accessible :order_id, :user_id, :ratee_id, :stars, :review

  belongs_to :user
  belongs_to :ratee, class_name: "User"
  belongs_to :order#, counter_cache: true
  
  validates_presence_of :stars
  
  def self.seller_rating(order)
    stars = case order.delivery_time
    when 0..3 then 5
    when 3..5 then 4
    when 5..7 then 3
    when 7..9 then 2
    when 9..14 then 1
    else 0 
    end

    rating = self.new(user_id: order.user_id, ratee_id: order.seller_id, stars: stars)
  end
  
  def self.buyer_rating(order)
    stars = case order.prompt_payment?
    when 0..30 then 5
    when 30..35 then 4
    when 35..40 then 3
    else 0 
    end
    
    rating = self.new(user_id: order.seller_id, ratee_id: order.user_id, stars: stars)
  end
end
