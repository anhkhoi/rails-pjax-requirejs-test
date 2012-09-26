module PjaxHelper
  def pjax_container(name, &block)
    content_tag(:div, block, "data-pjax-container" => name)
  end
end