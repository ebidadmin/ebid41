class CarModel < ActiveRecord::Base
  attr_accessible :car_brand_id, :name, :creator_id

  belongs_to :car_brand
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :car_variants, dependent: :destroy
  has_many :cart_entries
  has_many :entries
  
  validates_presence_of :car_brand_id, :name
  
  
end
