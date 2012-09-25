Then /^I should see the heading "(.*?)"$/ do |heading|
  page.should have_css("h1, h2, h3, h4, h5, h6", text: heading)
end
