module ApplicationHelper
  def set_title(title)
    content_for(:title, title)
  end
  
  def title_tag
    content_tag(:title) do
      content_for?(:title) ? content_for(:title) : "PJAX RequireJS Test"
    end
  end
end
