class Profile < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :branch_id, :first_name, :last_name, :rank_id, :phone, :fax, :birthdate

  belongs_to :user
  belongs_to :company
  belongs_to :branch
  belongs_to :rank
  
  def to_s
    [first_name, last_name].join(" ") 
  end  
  
  def fullname
    to_s
  end
  
  def shortname
    [first_name[0], last_name].join(" ")
  end
  
  def rank_name
    self.rank.name
  end
  
end
