require "requirejs-rails"

module Jasminerice
  module HelperMethods
    def self.included(base)
      base.class_eval do
        include RequirejsHelper
        helper_method :requirejs_include_tag
      end
    end
  end
end