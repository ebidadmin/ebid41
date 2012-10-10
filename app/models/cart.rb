class Cart < ActiveRecord::Base
  attr_accessible :name, :creator_id

  belongs_to :user
  has_one :cart_entry, dependent: :destroy
  has_many :cart_items, dependent: :destroy
  

  def add(car_part)
    ci = cart_items.create(car_part_id: car_part, specs: "")
    ci
  end
end
