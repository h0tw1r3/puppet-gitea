# frozen_string_literal: true

require 'pp'

litmus_cleanup = false

desc "Provision machines, run acceptance tests, and tear down"
task :acceptance, [:group, :tag] do |_task, args|
  args.with_defaults(group: 'default', tag: nil)
  litmus_cleanup = (ENV.fetch('LITMUS_teardown', true).to_s.downcase.match?(%r{(true|auto)}))
  Rake::Task['spec_prep'].invoke
  Rake::Task['litmus:provision_list'].invoke args[:group]
  Rake::Task['litmus:install_agent'].invoke
  Rake::Task['litmus:install_modules_from_fixtures'].invoke
  begin
    Rake::Task['litmus:acceptance:parallel'].invoke args[:tag]
  rescue
    litmus_cleanup = false if ENV.fetch('LITMUS_teardown', '').downcase == 'auto'
    raise
  end
end

task :acceptance_cleanup do
  # return unless $!.nil? # No cleanup on error
  next unless litmus_cleanup # No cleanup if flag is false
  Rake::Task['litmus:tear_down'].invoke
end
at_exit { Rake::Task['acceptance_cleanup'].invoke }

namespace :litmus do
  desc 'Run tests against all machines in the inventory file'
  task :acceptance, [:tag] do |_task, args|
    args.with_defaults(tag: nil)

    Rake::Task.tasks().select {|t| t.to_s =~ %r{^litmus:acceptance:(?!(localhost|parallel)$)} }.each do |_atask|
      puts "Running task #{_atask.to_s}"
      _atask.invoke(*args)
    end
  end

  desc 'install all fixture modules'
  task :install_modules_from_fixtures, [:resolve_dependencies] do |_task, args|
    args.with_defaults(resolve_dependencies: false)

    Rake::Task['spec_prep'].invoke
    Rake::Task['litmus:install_modules_from_directory'].invoke(nil, nil, nil, !args[:resolve_dependencies])
  end
end

# Patch docker targets in inventory to support DOCKER_HOST environment variable
task :patch_docker_inventory do
  require 'yaml'
  require 'uri'

  hostname = (ENV['DOCKER_HOST'].nil? || ENV['DOCKER_HOST'].empty?) ? 'localhost' : URI.parse(ENV['DOCKER_HOST']).host || ENV['DOCKER_HOST']
  begin
    docker_context = JSON.parse(run_local_command('docker context inspect'))[0]
    docker_uri = URI.parse(docker_context['Endpoints']['docker']['Host'])
    hostname = docker_uri.host unless docker_uri.host.nil? || docker_uri.host.empty?
  rescue RuntimeError
    # old clients
  end

  if hostname != 'localhost'
    inventory_fn = "#{__dir__}/../spec/fixtures/litmus_inventory.yaml"
    data = YAML.load_file(inventory_fn)
    data['groups'].map do |group|
      if group['targets'].size > 0
        group['targets'].map do |target|
          target['uri'].gsub!('localhost', hostname) if target['facts']['provisioner'] == 'docker' && target['uri'] =~ %r{^localhost:}
        end
      end
    end
    File.open(inventory_fn, 'w') { |f| f.write(data.to_yaml) }
  end
end

Rake::Task['litmus:provision'].enhance do
  Rake::Task['patch_docker_inventory'].execute
end
Rake::Task['litmus:provision_list'].enhance do
  Rake::Task['patch_docker_inventory'].execute
end
