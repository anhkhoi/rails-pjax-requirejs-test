class JavascriptIncludeProcessor < Sprockets::Processor
  def evaluate(context, locals)
    data.gsub(/\$javascript_paths/) do
      asset_dictionary.to_json
    end
  end
  
  def environment
    Rails.application.assets
  end
  
  def asset_dictionary
    asset_list.inject({}) do |result, asset|
      result.merge({ asset.logical_path => asset.digest_path })
    end
  end
  
  def asset_list
    environment.index.instance_variable_get(:@assets).values.select do |asset|
      asset.digest_path =~ /\.js$/
    end
  end
end

Rails.application.assets.register_bundle_processor("application/javascript", JavascriptIncludeProcessor)