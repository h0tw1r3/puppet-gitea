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
) {
  $configuration = deep_merge($default_configuration, $custom_configuration)

  file { [
      $gitea::runner::path,
    ]:
      ensure => directory,
      owner  => $gitea::runner::owner,
      group  => $gitea::runner::group,
  }

  $runner_configuration = {
    'path'    => "${gitea::runner::path}/act-runner-config.yaml",
    'require' => File[$gitea::runner::path],
    #'notify'  => Class['gitea::runner::service'],
  }

  file { $runner_configuration['path']:
    ensure  => file,
    owner   => $gitea::runner::owner,
    group   => $gitea::runner::group,
    mode    => '0600',
    content => to_yaml($configuration),
  }
}
