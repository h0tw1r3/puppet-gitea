# @summary manages configuration files
#
# Manages custom api.ini and robots.txt
#
# @api private
#
class gitea::config {
  file { [
      "${gitea::work_path}/custom",
      "${gitea::work_path}/custom/conf",
    ]:
      ensure => directory,
      owner  => $gitea::owner,
      group  => $gitea::group,
  }

  $gitea_configuration = {
    'path'    => "${gitea::work_path}/custom/conf/app.ini",
    'require' => File["${gitea::work_path}/custom/conf"],
    'notify'  => Class['gitea::service'],
  }

  file { $gitea_configuration['path']:
    ensure => file,
    owner  => $gitea::owner,
    group  => $gitea::group,
    mode   => '0640',
  }
  inifile::create_ini_settings($gitea::configuration, $gitea_configuration)

  if $gitea::robots_txt != '' {
    file { "${gitea::work_path}/custom/robots.txt":
      mode   => '0644',
      source => $gitea::robots_txt,
    }
  }
}
