class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  def set_title(title)
    @title_tag_content = title
  end
end
