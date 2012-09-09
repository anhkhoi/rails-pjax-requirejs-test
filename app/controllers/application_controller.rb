class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  def pjax_layout
    "pjax"
  end
end
