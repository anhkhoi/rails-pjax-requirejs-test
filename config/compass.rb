# Require any additional compass plugins here.
project_type = :rails

unless Rails.env.production?
  # enable source maps
  sass_options = { debug_info: true }
end