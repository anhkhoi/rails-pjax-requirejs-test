class JavascriptIncludeProcessor < Sprockets::Processor
  def evaluate(context, locals)
    # look for $javascript_paths variable
    data.gsub(/\$javascript_paths/) do
      puts "$javascript_paths found in #{context.pathname}"
      javascripts = {}
      i = 0
      paths = []
      # read all the assets
      assets.each_file do |path|
        paths << path
      end
      puts "Completed compiling asset list"
      # loop through each path
      paths.each do |path|
        attributes = assets.attributes_for(path)
        # if it's a javascript file
        if attributes.content_type == "application/javascript"
          i += 1
          # load the requirement path
          basic_path = attributes.logical_path.gsub(/#{attributes.format_extension}$/, "")
          puts "Found basic path"
          # find the compiled asset
          asset = assets.find_asset("#{basic_path}#{attributes.format_extension}")
          puts "Found asset"
          # calculate the full path
          full_path = asset.digest_path
          puts "Found full path"
          # merge into the hash
          javascripts.merge!({ basic_path => full_path })
        end
      end
      puts "#{i} JS files found"
      # output as a JSON hash
      javascripts.to_json
    end
  end
  
  def assets
    Rails.application.assets
  end
end

Rails.application.assets.register_bundle_processor("application/javascript", JavascriptIncludeProcessor)