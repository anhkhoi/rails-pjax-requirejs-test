module PjaxHelper
  def pjax_container(name, &block)
    content_tag(:div, "data-pjax-container" => name, &block)
  end
end