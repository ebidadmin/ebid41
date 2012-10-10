class Term < ActiveRecord::Base
  attr_accessible :name
  
  has_many :entries
  
  def display
    if self.id == 1
      "Cash"
    else
      "#{name} days"
    end
  end
end
