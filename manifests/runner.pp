# @summary A short summary of the purpose of this class
#
# A description of what this class does
#
# @example
#   include gitea::runner
class gitea::runner (
  Hash $custom_configuration,
  Hash $default_configuration,
  String $owner,
  String $path,
  String $group,
) {
  $configuration = deep_merge($default_configuration, $custom_configuration)

  file { [
      "${path}/runner",
    ]:
      ensure => directory,
      owner  => $owner,
      group  => $group,
  }

  $runner_configuration = {
    'path'    => "${path}/runner/act-runner-config.yaml",
    'require' => File[$path],
    #'notify'  => Class['gitea::runner::service'],
  }

  file { $runner_configuration['path']:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0600',
    content => to_yaml($configuration),
  }

  file { '/usr/lib/systemd/system/gitea-runner.service' :
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    content => epp('gitea/systemd_runner.epp', {
        user  => $gitea::runner::owner,
        group => $gitea::runner::group,
        path  => $gitea::runner::path,
    }),
    notify  => Service['gitea-runner'],
  }
  service { 'gitea-runner':
    ensure => 'running',
    enable => true,
  }
}
