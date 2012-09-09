require 'spec_helper'

describe "guides/edit" do
  before(:each) do
    @guide = assign(:guide, stub_model(Guide,
      :title => "MyString",
      :description => "MyText"
    ))
  end

  it "renders the edit guide form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => guides_path(@guide), :method => "post" do
      assert_select "input#guide_title", :name => "guide[title]"
      assert_select "textarea#guide_description", :name => "guide[description]"
    end
  end
end
