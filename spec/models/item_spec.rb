require "spec_helper"

describe Item do
  # fields
  it { should have_field :title }
  it { should have_field :description }
  it { should be_timestamped_document }
  
  # associations
  it { should embed_many :guides }
  
  # validation
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
end
