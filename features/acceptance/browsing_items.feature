Feature: Browsing items
  In order to decide between different products
  As a visitor to the site
  I want to browse the different items in the catalogue
  
  @javascript
  Scenario: Viewing an item from the index
    Given an item exists called "iPhone"
    When I view the item index
    And I click on the item "iPhone"
    Then I should see the heading "iPhone"