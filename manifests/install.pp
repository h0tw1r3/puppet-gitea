# @summary download and install gitea
#
# Downloads and installs gitea, and manages the required directory structure
#
# @api private
#
# @param packages
#   List of system packages required by Gitea
# @param checksums
#   Hash of known version checksums. See data/checksums.yaml
#
class gitea::install (
  Array[String] $packages,
  Hash $checksums,
) {
  ensure_packages($packages)

  $bin_path = "${gitea::work_path}/gitea"

  file { [
      $gitea::work_path,
      $gitea::configuration['server']['APP_DATA_PATH'],
      $gitea::configuration['repository']['ROOT'],
      "${gitea::configuration['server']['APP_DATA_PATH']}/sessions",
    ]:
      ensure => 'directory',
      owner  => $gitea::owner,
      group  => $gitea::group,
  }

  $vars = Deferred('gitea::archive_resource', [$bin_path, $gitea::base_url, $checksums, $gitea::ensure, $gitea::checksum])

  archive { 'gitea':
    path          => $bin_path,
    source        => Deferred('inline_epp', ['<%= $source %>', $vars]),
    proxy_server  => $gitea::proxy,
    checksum      => Deferred('inline_epp', ['<%= $checksum %>', $vars]),
    checksum_type => Deferred('inline_epp', ['<%= $checksum_type %>', $vars]),
    cleanup       => false,
    extract       => false,
  }
  -> file { $bin_path:
    mode => '0755',
  }
}
