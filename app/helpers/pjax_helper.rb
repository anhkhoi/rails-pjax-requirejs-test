module PjaxHelper
  def pjax_container(name, html_options = {}, &block)
    content_tag(:div, html_options.merge("data-pjax-container" => name), &block)
  end
  
  def conditional_pjax_container(name, &block)
    if pjax_wants?(name)
      pjax_container(name, &block)
    end
  end
  
  def pjax_wants?(name)
    true
  end
end