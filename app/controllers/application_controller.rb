class ApplicationController < ActionController::Base
  protect_from_forgery
  
  before_filter :prepare_for_mobile
  
  respond_to :html, :mobile, :js
  

  protected
  def set_title(title)
    @title_tag_content = title
  end
  
  helper_method :request_from_mobile?
  def request_from_mobile?
    @request_from_mobile ||= (request.path =~ /^\/mobile(\/.*)?$/)
  end
  
  helper_method :desktop_url
  def desktop_url(url = request.url)
    desktop_path(url)
  end
  
  helper_method :desktop_path
  def desktop_path(path = request.path)
    path.gsub(/^(.*?\/\/.*?)?\/(mobile\/?)?(.*)$/, '\1/\3').freeze
  end
  
  helper_method :mobile_url
  def mobile_url(url = request.url)
    mobile_path(url)
  end
  
  helper_method :mobile_path
  def mobile_path(path = request.path)
    path.gsub(/^(.*?\/\/.*?)?\/(mobile\/?)?(.*)$/, '\1/mobile/\3').freeze
  end
  
  def prepare_for_mobile
    if request_from_mobile?
      request.format = :mobile
      params["mobile"] = "mobile"
    end
  end
  
  private
  def _compute_redirect_to_location(options)
    # ignore our direct calls for desktop/mobile URLs
    if options.kind_of?(String) && options.frozen?
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
