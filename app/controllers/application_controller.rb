class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prepare_for_mobile

  protected
  def set_title(title)
    @title_tag_content = title
  end
  
  def request_from_mobile?
    request.path =~ /^\/mobile\//
  end
  
  helper_method :desktop_url, :desktop_path, :mobile_url, :mobile_path
  def desktop_url
    if request_from_mobile?
      request.url.gsub(/^(.*?)\/mobile\//, '\1/')
    else
      request.url
    end
  end
  
  def desktop_path
    if request_from_mobile?
      request.path.gsub(/^(.*?)\/mobile\//, '\1/')
    else
      request.path
    end
  end
  
  def mobile_url
    if request_from_mobile?
      request.url
    else
      request.url.gsub(/^(.*?\/\/.*?)\/(.*)$/, '\1/mobile/\2')
    end
  end
  
  def mobile_path
    if request_from_mobile?
      request.path
    else
      request.path.gsub(/^(.*?\/\/.*?)\/(.*)$/, '\1/mobile/\2')
    end
  end
  
  def prepare_for_mobile
    if request_from_mobile?
      request.format = :mobile
      params["mobile"] = "mobile"
    end
  end
end
