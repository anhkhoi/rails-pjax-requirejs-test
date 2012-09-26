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
end
