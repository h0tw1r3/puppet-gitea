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
  String $version,
  String $gitea_url,
  String $token,
) {
  $configuration = deep_merge($default_configuration, $custom_configuration)
  $kernel = downcase($facts['kernel'])
  $arch = downcase($facts['architecture'])

  file { [
      "${path}/runner",
    ]:
      ensure => directory,
      owner  => $owner,
      group  => $group,
  }

  $runner_configuration = {
    'path'    => "${path}/act-runner-config.yaml",
    'require' => File[$path],
    'notify'  => Service['gitea-runner'],
  }

  file { "${path}/act_runner":
    ensure => file,
    owner  => $owner,
    group  => $group,
    mode   => '0700',
    source => "https://dl.gitea.com/act_runner/${version}/act_runner-${version}-${kernel}-${arch}",
  }

  file { $runner_configuration['path']:
    ensure  => file,
    owner   => $owner,
    group   => $group,
    mode    => '0600',
    content => to_yaml($configuration),
  }

  exec { 'register_runner':
    command => "${path}/act_runner register --no-interactive --instance ${gitea_url} --token ${token} --config ${path}/act-runner-config.yaml",
    onlyif  => "/usr/bin/test ! -e ${path}/.runner",
    path    => $path,
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
