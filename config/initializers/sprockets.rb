class JavascriptIncludeProcessor < Sprockets::Processor
  def evaluate(context, locals)
    # look for $javascript_paths variable
    data.gsub(/\$javascript_paths/) do
      javascripts = {}
      # read all the assets
      assets.each_file do |path|
        attributes = assets.attributes_for(path)
        # if it's a javascript file
        if attributes.content_type == "application/javascript"
          # load the requirement path
          basic_path = attributes.logical_path.gsub(/#{attributes.format_extension}$/, "")
          # calculate the digest
          digest = assets.file_digest(path)
          # translate that into a full path
          asset_path = "#{basic_path}-#{digest}"
          # merge into the hash
          javascripts.merge!({ basic_path => asset_path })
        end
      end
      # output as a JSON hash
      javascripts.to_json
    end
  end
  
  def assets
    Rails.application.assets
  end
end

Rails.application.assets.register_preprocessor("application/javascript", JavascriptIncludeProcessor)