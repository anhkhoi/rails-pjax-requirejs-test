require "requirejs-rails"

module Jasminerice
  module HelperMethods
    def self.included(base)
      base.class_eval do
        helper RequirejsHelper
      end
    end
  end
end