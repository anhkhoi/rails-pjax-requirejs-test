Given /^an item exists called "(.*?)"$/ do |title|
  FactoryGirl.create(:item, title: title)
end

When /^I view the item index$/ do
  item.index
end

When /^I click on the item "(.*?)"$/ do |title|
  item.open_by_title(title)
end

Then /^I should see the item "(.*?)"$/ do |title|
  record = Item.where(title: title).first
  current_url.should == item.url(record)
end