class JavascriptIncludeProcessor < Sprockets::Processor
  def evaluate(context, locals)
    data.gsub(/\$javascript_paths/) do
      asset_dictionary.to_json
    end
  end
  
  def asset_list
    @files ||= begin
      environment.paths.inject([]) do |files, directory|
        Dir[File.join(directory, "**", "*")].each do |file|
          # ensure a JS file
          next unless file =~ /\.js$|\.js\./
          # build the asset
          logical_path = file.gsub(/^#{directory}\/?/, "").gsub(/\.js\..*?$/, ".js")
          # add the asset to the array of files
          files << Sprockets::Asset.new(environment, logical_path, file)
        end
        # return the result
        files
      end
    end
  end
  
  def environment
    Rails.application.assets
  end
  
  def asset_dictionary
    asset_list.inject({}) do |result, asset|
      result.merge({ asset.logical_path.gsub(/\.js$/, "") => asset.digest_path.gsub(/\.js$/, "") })
    end
  end
  
  def asset_index
    environment.index
  end
end

Rails.application.assets.register_bundle_processor("application/javascript", JavascriptIncludeProcessor)