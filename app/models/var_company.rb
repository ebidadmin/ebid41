class VarCompany < ActiveRecord::Base
  before_save :capitalize
  
  attr_accessible :name, :creator_id
  has_many :variances
  belongs_to :creator, :class_name => "User", :foreign_key => "creator_id"
  
  validates_presence_of :name

  def to_s
    name
  end
  
  private
  
  def capitalize
    name.titleize
  end
end
