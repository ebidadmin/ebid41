class Role < ActiveRecord::Base
  has_and_belongs_to_many :users#, :join_table => :users_roles
  belongs_to :resource, :polymorphic => true
  has_many :companies, :foreign_key => "primary_role"
end
