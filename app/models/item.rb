class Item
  include Mongoid::Document
  include Mongoid::Timestamps

  # fields
  field :title, type: String
  field :description, type: String
  
  # associations
  embeds_many :guides, inverse_of: :item
  
  # validation
  validates :title, :description, presence: true
end
