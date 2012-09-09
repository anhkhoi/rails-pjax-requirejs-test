class Guide
  include Mongoid::Document
  include Mongoid::Timestamps
  
  # fields
  field :title, type: String
  field :description, type: String
  
  # associations
  embedded_in :item, inverse_of: :guides
  
  # validation
  validates :title, :description, presence: true
end
