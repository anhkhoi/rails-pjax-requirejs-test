class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :title, type: String
  field :description, type: String
  
  # validation
  validates :title, :description, presence: true
end
