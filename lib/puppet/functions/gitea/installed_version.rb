# frozen_string_literal: true

# @summary
#   Returns the installed gitea version
Puppet::Functions.create_function(:"gitea::installed_version") do
  dispatch :installed_version do
    param 'String', :a
    return_type 'Variant[String,Undef]'
  end
  def installed_version(x)
    IO.popen([x, '-v']).read.scan(%r{version ([^\s]+) }).first.first
  rescue Errno::ENOENT
    nil
  end
end
