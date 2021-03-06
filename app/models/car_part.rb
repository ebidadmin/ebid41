class CarPart < ActiveRecord::Base
  # include Tire::Model::Search
  # include Tire::Model::Callbacks

  attr_accessible :name, :creator_id
  
  before_save :strip_blanks
  
  belongs_to :creator, class_name: "User", foreign_key: "creator_id"
  
  has_many :cart_items
  has_many :line_items
  has_many :entries, through: :line_items
  has_many :bids, through: :line_items

  validates_presence_of :name
  validates_uniqueness_of :name, message: "Sorry, that car part is already in our list. You can either cancel, or type a unique name for the new part."

  default_scope order(:name)

  def to_s
    name
  end

  # def self.search(params={})
  #   tire.search(page: params[:page], per_page: 32) do
  #     query { string params[:query], default_operator: "AND" } if params[:query].present?
  #     highlight :name, :body, :options => { :tag => "<span class='highlight'>" }
  #   end
  # end
  
  private
  
  def strip_blanks
    self.name.strip
  end
  
  
end
