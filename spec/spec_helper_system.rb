require 'rspec-system/spec_helper'
require 'rspec-system-puppet/helpers'
require 'rspec-system-serverspec/helpers'

module RSpecSystem
  class NodeSet::Vagrant < RSpecSystem::NodeSet::Base
    def extra_disks(node, ps)
      [
        {:path => "#{File.expand_path('~')}/vagrant/#{node}_#{ps['box']}_sdb.vdi", :size => 1*1024},
        {:path => "#{File.expand_path('~')}/vagrant/#{node}_#{ps['box']}_sdc.vdi", :size => 1*1024},
      ]
    end

    def create_vagrantfile
      log.info "[Vagrant#create_vagrantfile] Creating vagrant file here: #{@vagrant_path}"
      FileUtils.mkdir_p(@vagrant_path)
      File.open(File.expand_path(File.join(@vagrant_path, "Vagrantfile")), 'w') do |f|
        f.write("Vagrant.configure('2') do |config|\n")
        nodes.each do |k,v|
          log.debug "Filling in content for #{k}"

          ps = v.provider_specifics['vagrant']

          node_config = "  config.vm.define '#{k}' do |v|\n"
          node_config << "    v.vm.hostname = '#{k}'\n"
          node_config << "    v.vm.box = '#{ps['box']}'\n"
          node_config << "    v.vm.box_url = '#{ps['box_url']}'\n" unless ps['box_url'].nil?
          node_config << "    v.vm.provider :virtualbox do |vb|\n"
          extra_disks(k, ps).each_with_index do |disk, index|
            node_config << "      vb.customize ['createhd', '--filename', '#{disk[:path]}', '--size', #{disk[:size]}]\n"
            node_config << "      vb.customize ['storageattach', :id, '--storagectl', 'SATA Controller', '--port', #{index+1}, '--device', 0, '--type', 'hdd', '--medium', '#{disk[:path]}']\n"
          end
          node_config << "    end\n"
          node_config << "  end\n"

          f.write(node_config)
        end
        f.write("end\n")
      end
      log.debug "[Vagrant#create_vagrantfile] Finished creating vagrant file"
      nil
    end
  end
end

include RSpecSystemPuppet::Helpers
include Serverspec::Helper::RSpecSystem
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  # Project root for the this module's code
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Enable colour in Jenkins
  c.tty = true

  c.include RSpecSystemPuppet::Helpers

  # This is where we 'setup' the nodes before running our tests
  c.before :suite do
    # Install puppet
    puppet_install
    puppet_master_install

    shell('puppet module install puppetlabs/stdlib --modulepath /etc/puppet/modules')
    shell('puppet module install stahnma/epel --modulepath /etc/puppet/modules')
    shell('puppet module install treydock/gpg_key --modulepath /etc/puppet/modules')
    shell('puppet module install saz/sudo --modulepath /etc/puppet/modules')

    # Temporary until the zabbix20 module is added to the Forge
    shell('yum -y install git')
    shell('git clone git://github.com/treydock/puppet-zabbix20.git /etc/puppet/modules/zabbix20')
    shell('puppet module install puppetlabs/firewall --modulepath /etc/puppet/modules')

    puppet_module_install(:source => proj_root, :module_name => 'zfsonlinux')
  end
end