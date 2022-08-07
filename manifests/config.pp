# Class: gitea::config
# ===========================
#
# Applies configuration for `::gitea` class to system.
#
# Authors
# -------
#
# Jeffrey Clark <h0tw1r3@users.noreply.github.com>
# Daniel S. Reichenbach <daniel@kogitoapp.com>
#
# Copyright
# ---------
#
# Copyright 2022 Jeffrey Clark <https://github.com/h0tw1r3>
# Copyright 2016-2019 Daniel S. Reichenbach <https://kogitoapp.com>
#
class gitea::config {
  file { [
    "${gitea::work_path}/custom",
    "${gitea::work_path}/custom/conf",
    "${gitea::work_path}/custom/public",
    "${gitea::work_path}/custom/public/css",
    "${gitea::work_path}/custom/public/img",
    "${gitea::work_path}/custom/templates",
    "${gitea::work_path}/custom/templates/custom",
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

  inifile::create_ini_settings($gitea::configuration, $gitea_configuration)

  if $gitea::robots_txt != '' {
    file { "${gitea::work_path}/custom/robots.txt":
      mode   => '0644',
      source => $gitea::robots_txt,
    }
  }
}
