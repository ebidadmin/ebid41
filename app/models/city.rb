class City < ActiveRecord::Base
  attr_accessible :user_id, :name, :region_id
  belongs_to :region
  has_many :entries
  
  
  def to_s
    name
  end
  
end
