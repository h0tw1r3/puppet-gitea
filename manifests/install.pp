# @summary download and install gitea
#
# Downloads and installs gitea, and manages the required directory structure
#
# @api private
#
class gitea::install {
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

  $source_url = "${gitea::base_url}/${gitea::version}/gitea-${gitea::version}-${kernel_down}-${arch}"
  $bin_path = "${gitea::work_path}/gitea"

  package { 'git': }
  -> archive { 'gitea':
    path          => $bin_path,
    source        => $source_url,
    proxy_server  => $gitea::proxy,
    checksum      => $gitea::checksum,
    checksum_type => 'sha256',
    cleanup       => false,
    extract       => false,
  }
  -> file { $bin_path:
    mode => '0755',
  }

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
