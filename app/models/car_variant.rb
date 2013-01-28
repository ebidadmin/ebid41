class CarVariant < ActiveRecord::Base
  attr_accessible :car_brand_id, :car_model_id, :name, :start_year, :end_year, :creator_id

  belongs_to :car_brand
  belongs_to :car_model, counter_cache: true
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  has_many :cart_entries
  has_many :entries
  
  validates_presence_of :car_brand_id, :car_model_id, :name
  
  def full_name
    "#{car_brand} #{car_model} #{name}"
  end
    
end
