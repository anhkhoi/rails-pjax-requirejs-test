require_relative "lib/erb_hash_binding"

Capistrano::Configuration.instance(:must_exist).load do |config|
  # Where to store the monit configuration templates (locally)
  set :initd_template_dir, File.join(File.dirname(__FILE__), "templates/init.d")

  def upload_initd_config(name, options)
    # load our template name
    template_name = options.delete(:template) || "default.erb"
    # load the template contents
    template_path = File.join(initd_template_dir, template_name)
    template_data = File.read(template_path)
    # define the destination
    destination = options.delete(:destination) || File.join("/etc/init.d", name)
    # define the temporary upload location
    tempfile_path = "/tmp/initd_#{File.basename(destination)}"
    # render the template with the options
    data = ErbHashBinding.new({ name: name }.merge(options)).render(template_data)
    # upload the config to the server
    put(data, tempfile_path, mode: 0755)
    # delete any existing file
    sudo "rm -f #{destination}"
    # move it to the right place
    sudo "mv #{tempfile_path} #{destination}"
  end
end