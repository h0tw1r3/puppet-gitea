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

  $kernel_down = downcase($facts['kernel'])

  case $facts['os']['architecture'] {
    /(x86_64)/: {
      $arch = 'amd64'
    }
    /(armv7l)/: {
      $arch = 'arm-6'
    }
    /(x86)/: {
      $arch = '386'
    }
    default: {
      $arch = $facts['os']['architecture']
    }
  }

  $sorted_versions = sort($checksums.keys) |$a,$b| { versioncmp($a, $b) }
  $installed_version = Deferred('gitea::installed_version', ["${bin_path}/gitea"])
  $new_version = ($installed_version =~ Regexp[/\d+\.\d+\.\d+/]) ? {
    true    => $sorted_versions.filter |$version| { (versioncmp($version, $installed_version) > 0) }[0],
    default => $sorted_versions[-1]
  }

  $version = $gitea::ensure ? {
    'latest'    => $new_version,
    'installed' => $installed_version ? {
      false   => $new_version,
      default => $installed_version,
    },
    default     => $gitea::ensure,
  }

  if $version != $sorted_versions[-1] {
    notify { "gitea ${version} upgradable to ${sorted_versions[-1]}": }
  }

  $checksum = $gitea::checksum ? {
    /.+/    => $gitea::checksum,
    default => $checksums[$version][$kernel_down][$arch],
  }

  $source_url = "${gitea::base_url}/${version}/gitea-${version}-${kernel_down}-${arch}"

  file { "${bin_path}/gitea":
    source   => $source_url,
    checksum => $checksum,
    mode     => '0755',
  }

  #archive { 'gitea':
  #  path          => $bin_path,
  #  source        => $source_url,
  #  proxy_server  => $gitea::proxy,
  #  checksum      => $checksum,
  #  checksum_type => 'sha256',
  #  cleanup       => false,
  #  extract       => false,
  #}
  #-> file { $bin_path:
  #  mode => '0755',
  #}

  # Workaround Debian systemd tmp permissions bug
  Exec <| title == 'systemd-tmpfiles' |> {
    returns => [0,73]
  }

  systemd::tmpfile { 'gitea.conf':
    content => epp($gitea::tmpfile_epp, {
        user     => $gitea::owner,
        group    => $gitea::group,
        run_path => $gitea::run_path,
    }),
  }
  -> systemd::unit_file { 'gitea.service':
    content => epp($gitea::service_epp, {
        user      => $gitea::owner,
        group     => $gitea::group,
        run_path  => $gitea::run_path,
        work_path => $gitea::work_path,
        bin_path  => $bin_path,
    }),
  }
}
