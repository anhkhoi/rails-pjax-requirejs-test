require "ostruct"
require "erb"

class ErbHashBinding < OpenStruct
  def render(template)
    ERB.new(template).result(binding)
  end
end
