class CartItem < ActiveRecord::Base
  attr_accessible :car_part_id, :quantity, :specs

  belongs_to :cart
  belongs_to :car_part
end
