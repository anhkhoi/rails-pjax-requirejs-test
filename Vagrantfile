# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant::Config.run do |config|
  config.vm.define :app do |c|
    c.vm.box = "base"
    c.vm.forward_port 8080, 8080
    c.vm.forward_port 80, 3000
  end
end
