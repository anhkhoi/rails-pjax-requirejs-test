class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prepare_for_mobile

  protected
  def set_title(title)
    @title_tag_content = title
  end
  
  helper_method :request_from_mobile?
  def request_from_mobile?
    @request_from_mobile ||= (request.path =~ /^\/mobile\//)
  end
  
  helper_method :desktop_url
  def desktop_url(url = request.url)
    if request_from_mobile?
      url.gsub(/^(.*?)\/mobile\//, '\1/')
    else
      url
    end
  end
  
  helper_method :desktop_path
  def desktop_path(path = request.path)
    if request_from_mobile?
      path.gsub(/^(.*?)\/mobile\//, '\1/')
    else
      path
    end
  end
  
  helper_method :mobile_url
  def mobile_url(url = request.url)
    mobile_path(url)
  end
  
  helper_method :mobile_path
  def mobile_path(path = request.path)
    path.gsub(/^(.*?\/\/.*?)?\/(mobile\/)?(.*)$/, '\1/mobile/\3')
  end
  
  def prepare_for_mobile
    if request_from_mobile?
      request.format = :mobile
      params["mobile"] = "mobile"
    end
  end
end
