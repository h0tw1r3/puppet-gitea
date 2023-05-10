# frozen_string_literal: true

require 'puppet_litmus'
require 'spec_helper_acceptance_local' if File.file?(File.join(File.dirname(__FILE__), 'spec_helper_acceptance_local.rb'))

PuppetLitmus.configure!

RSpec.configure do |c|
  # Project root
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  # Readable test descriptions
  c.formatter = :documentation

  # Configure all nodes in nodeset
  c.before :suite do
    # Install module and dependencies
    puppet_module_install(source: proj_root, module_name: 'gitea')
    hosts.each do |host|
      on host, puppet('module', 'install', 'puppetlabs-stdlib'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'puppetlabs-inifile'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'puppet-archive'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'puppet-extlib'), acceptable_exit_codes: [0]
      on host, puppet('module', 'install', 'puppet-systemd'), acceptable_exit_codes: [0]
    end
  end
end
