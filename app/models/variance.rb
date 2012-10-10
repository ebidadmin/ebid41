class Variance < ActiveRecord::Base
  attr_accessible :user_id, :company_id, :entry_id, :var_company_id, :var_items_attributes, :discount
  attr_accessor :discount
  
  belongs_to :user
  belongs_to :company
  belongs_to :entry
  belongs_to :var_company
  has_many :var_items, dependent: :destroy
  accepts_nested_attributes_for :var_items#, allow_destroy: true, reject_if: lambda { |vi| ( vi[:var_base].blank?) }
  
  DISCOUNTS = %w(5 10 15 20 25 30 35 40)
  TYPES = %w(original replacement surplus)
  
  def populate(user, discount, entry)
    if user.has_role? :admin
      self.company_id = entry.company_id
    else
      self.company_id = user.profile.company_id
    end
    self.var_items.each { |vi| vi.populate(discount) }
  end
  
end
