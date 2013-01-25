class User < ActiveRecord::Base
  rolify
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  devise :encryptable, :encryptor => :authlogic_sha512

  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :opt_in, 
    :profile_attributes, :role_ids, :enabled
  
  has_one :profile, dependent: :destroy
  accepts_nested_attributes_for :profile, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  has_one :company, through: :profile
  has_one :branch, through: :profile
  has_and_belongs_to_many :roles
  accepts_nested_attributes_for :roles, allow_destroy: true, reject_if: proc { |obj| obj.blank? }
  
  has_many :creators, through: :car_models
  has_many :creators, through: :car_variants
  has_many :creators, through: :car_parts
  has_many :entries, dependent: :destroy
  has_many :bids, dependent: :destroy
  has_many :orders, dependent: :destroy
  has_many :sellers, through: :orders
  has_many :messages, dependent: :destroy
  has_many :receivers, through: :messages
  has_many :buyers, through: :fees
  has_many :sellers, through: :fees
  has_many :cities
  has_many :variances, dependent: :destroy
  has_many :creators, through: :var_companies

  scope :opt_in, where(opt_in: true)
  scope :enabled, where(enabled: true)

  delegate :address1, :address2, :city, to: :branch, allow_nil:true
  delegate :first_name, :shortname, :phone, :fax, :birthdate, :rank_name, :fullname, to: :profile, allow_nil:true
  delegate :nickname, to: :company

  validates_presence_of [:password, :password_confirmation], :if => :password_required?
  validates_presence_of :email
  validates_associated :profile
  
  def to_s
    username
  end
  
  def password_required? 
    encrypted_password.blank? || !password.blank?
  end
  
end
