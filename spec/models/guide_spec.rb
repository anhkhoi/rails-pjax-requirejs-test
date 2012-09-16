require "spec_helper"

describe Guide do
  # fields
  it { should have_field :title }
  it { should have_field :description }
  it { should be_timestamped_document }
  
  # associations
  it { should be_embedded_in(:item).as_inverse_of(:guides) }
  
  # validation
  it { should validate_presence_of :title }
  it { should validate_presence_of :description }
end
