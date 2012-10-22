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
  
  # callbacks
  after_save :touch_item
  after_destroy :touch_item
  
  # updates the parent item's timestamps
  def touch_item
    item.touch
  end
end
