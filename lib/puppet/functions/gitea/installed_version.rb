# frozen_string_literal: true

# https://github.com/puppetlabs/puppet-specifications/blob/master/language/func-api.md#the-4x-api
Puppet::Functions.create_function(:"gitea::installed_version") do
  dispatch :installed_version do
    param 'String', :a
    return_type 'String'
  end
  def installed_version(x)
    IO.popen([x, '-v']).read.chomp.scan(%r{version ([^\s]+) }).first.first
  rescue Errno::ENOENT
    nil
  end
end
