module PageObjects
  class Item
    include Capybara::DSL
    include Rails.application.routes.url_helpers

    def index
      visit items_path
    end
    
    def url(item)
      item_url(item)
    end

    def open(item)
      find("a[href='#{item_path(item)}']").click
    end
    
    def open_by_title(title)
      record = ::Item.where(title: title).first
      open(record)
    end

    def submit_item(attributes = {})
      fill_in "#new_item_title", with: attributes[:title]
      fill_in "#new_item_description", with: attributes[:description]
    end
  end

  # helper method to access the page object
  def item
    PageObjects::Item.new
  end
end