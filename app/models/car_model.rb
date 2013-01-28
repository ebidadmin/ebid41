class CarModel < ActiveRecord::Base
  attr_accessible :car_brand_id, :name, :creator_id, :creator

  belongs_to :car_brand, counter_cache: true
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  has_many :car_variants, dependent: :destroy
  has_many :cart_entries
  has_many :entries
  
  validates_presence_of :car_brand_id, :name
  
  def to_s
    name
  end
  
  def full_name
    "#{car_brand} #{name}"
  end
end
