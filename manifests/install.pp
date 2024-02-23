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
      "${$gitea::work_path}/log",
      $gitea::configuration['server']['APP_DATA_PATH'],
      $gitea::configuration['repository']['ROOT'],
      "${gitea::configuration['server']['APP_DATA_PATH']}/sessions",
    ]:
      ensure => 'directory',
      owner  => $gitea::owner,
      group  => $gitea::group,
  }

  if $gitea::ensure =~ Stdlib::HTTPurl {
    if $gitea::checksum !~ String[64] {
      fail('gitea::checksum parameter requires sha256 checksum')
    }
    $vars = {
      source        => $gitea::ensure,
      checksum      => $gitea::checksum,
      checksum_type => 'sha256',
    }
  } else {
    $vars = Deferred('gitea::archive_resource', [$bin_path, $gitea::base_url, $checksums, $gitea::ensure, $gitea::checksum])
  }

  archive { 'gitea':
    path          => "${bin_path}.stage",
    source        => Deferred('inline_epp', ['<%= $source %>', $vars]),
    proxy_server  => $gitea::proxy,
    checksum      => Deferred('inline_epp', ['<%= $checksum %>', $vars]),
    checksum_type => Deferred('inline_epp', ['<%= $checksum_type %>', $vars]),
    cleanup       => false,
    extract       => false,
  }
  -> file { "${bin_path}.stage":
    mode => '0755',
  }
  # basic check to ensure the updated release executes
  -> exec { 'gitea-release-check':
    cwd         => $gitea::work_path,
    environment => [
      "HOME=${gitea::work_path}",
      "USER=${gitea::owner}",
      "GITEA_WORK_DIR=${gitea::work_path}",
    ],
    user        => $gitea::owner,
    umask       => $gitea::umask,
    command     => "${bin_path}.stage doctor check --run paths --log-file '' || ${bin_path}.stage doctor --run paths --log-file ''",
    onlyif      => [
      "/usr/bin/env test -f ${gitea::work_path}/custom/conf/app.ini",
      "/usr/bin/env cmp ${bin_path} ${bin_path}.stage; /usr/bin/env test $? -eq 1",
    ],
  }
  -> file { $bin_path:
    source => "${bin_path}.stage",
    mode   => '0755',
  }
}
