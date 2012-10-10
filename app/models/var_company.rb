class VarCompany < ActiveRecord::Base
  attr_accessible :name, :creator_id
  has_many :variances

  def to_s
    name
  end
end
