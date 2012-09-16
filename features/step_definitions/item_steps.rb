Given /^an item exists called "(.*?)"$/ do |title|
  FactoryGirl.create(:item, title: title)
end

When /^I view the item index$/ do
  visit items_path
end

When /^I click on the item "(.*?)"$/ do |title|
  item = Item.where(title: title).first
  find("a[href='#{item_path(item)}']").click
end

Then /^I should see the heading "(.*?)"$/ do |heading|
  page.should have_css("h1, h2, h3, h4, h5, h6", text: heading)
end