class JavascriptIncludeProcessor < Sprockets::Processor
  def evaluate(context, locals)
    # look for $javascript_paths variable
    data.gsub(/\$javascript_paths/) do
      javascripts = {}
      # read all the assets
      assets.each_file do |path|
        puts "one"
        attributes = assets.attributes_for(path)
        puts "two"
        # if it's a javascript file
        if attributes.content_type == "application/javascript"
          puts "three"
          # load the requirement path
          basic_path = attributes.logical_path.gsub(/#{attributes.format_extension}$/, "")
          puts "four"
          # calculate the full path
          full_path = context.asset_path("#{basic_path}#{attributes.format_extension}")
          puts "five"
          full_path = full_path.gsub(/#{attributes.format_extension}$/, "")
          puts "six"
          # merge into the hash
          javascripts.merge!({ basic_path => full_path })
          puts "seven"
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

Rails.application.assets.register_bundle_processor("application/javascript", JavascriptIncludeProcessor)