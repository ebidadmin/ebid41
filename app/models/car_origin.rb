class CarOrigin < ActiveRecord::Base
  attr_accessible :name
  has_many :car_brands
  
  def to_s
    name
  end
end
