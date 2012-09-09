require 'spec_helper'

describe "guides/new" do
  before(:each) do
    assign(:guide, stub_model(Guide,
      :title => "MyString",
      :description => "MyText"
    ).as_new_record)
  end

  it "renders new guide form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form", :action => guides_path, :method => "post" do
      assert_select "input#guide_title", :name => "guide[title]"
      assert_select "textarea#guide_description", :name => "guide[description]"
    end
  end
end
