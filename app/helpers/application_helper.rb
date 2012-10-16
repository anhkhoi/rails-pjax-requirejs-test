module ApplicationHelper
  def set_title(title)
    content_for(:title, title)
  end
  
  def title_tag
    content_tag(:title) do
      if content_for?(:title)
        content_for(:title)
      elsif @title_tag_content
         @title_tag_content
      else
        t("app.default_title", default: t("app.name"))
      end
    end
  end
  
  def url_for(*args)
    # ignore our direct calls for desktop/mobile URLs
    if args.size == 1 && args.first.frozen?
      super
    # if it's from a mobile
    elsif request_from_mobile?
      # mobilify the url
      mobile_url(super)
    # if it's a desktop request
    else
      # process as normal
      super
    end
  end
end
