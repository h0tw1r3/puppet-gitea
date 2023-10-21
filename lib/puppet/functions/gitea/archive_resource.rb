# frozen_string_literal: true

# @summary
#   Returns source, checksum, and checksum_type params for downloading a gitea
#   release with the archive resource
Puppet::Functions.create_function(:"gitea::archive_resource", Puppet::Functions::InternalFunction) do
  dispatch :archive_resource do
    scope_param
    param 'String', :gitea_bin
    param 'String', :base_url
    param 'Hash', :checksums
    param 'String', :version
    optional_param 'Variant[String,Undef]', :checksum_value
    return_type 'Hash'
  end

  def archive_resource(scope, gitea_bin, base_url, checksums, version, checksum_value = nil)
    versions = checksums.keys.sort_by { |v| Gem::Version.new(v) }
    next_version = versions[-1]
    kernel = scope['facts']['kernel'].downcase
    os_arch = scope['facts']['os']['architecture']
    arch = case os_arch
           when 'x86_64' then 'amd64'
           when 'arm7l' then 'arm-6'
           when 'x86' then '386'
           else os_arch
           end
    installed_version = scope.call_function('gitea::installed_version', gitea_bin)

    unless installed_version.nil? || installed_version.empty?
      find_next_version = versions.select { |v| (Gem::Version.new(v) > Gem::Version.new(installed_version)) }.detect.first
      unless find_next_version.nil? || find_next_version.empty?
        next_version = find_next_version
      end
    end

    if version == 'latest'
      version = next_version
      Puppet.notice("upgrading gitea v#{installed_version} to v#{next_version}") if installed_version != version
    elsif version == 'installed'
      version = installed_version || next_version
    end

    if checksum_value.nil? || checksum_value.empty?
      begin
        checksum_value = checksums[version][kernel][arch]
      rescue
        raise(Puppet::ParseError, "checksum required for gitea version #{version}")
      end
    end

    x = {}
    x['source'] = "#{base_url}/#{version}/gitea-#{version}-#{kernel}-#{arch}"
    x['checksum'] = checksum_value
    x['checksum_type'] = 'sha256'

    x
  end
end
