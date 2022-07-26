# Class: gitea::service
# ===========================
#
# Manages services for the `::gitea` class.
#
# Parameters
# ----------
#
# @param manage_service
#  Should we manage a service definition for Gitea?
#
# @param service_provider
#  Which service provider do we use?
#
# @param installation_directory
#  Target directory to hold the gitea installation. Default: '/opt/gitea'
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
class gitea::service (
  Boolean $manage_service        = $gitea::manage_service,
  String $service_provider       = $gitea::service_provider,
  String $installation_directory = $gitea::installation_directory,
  ) {

  if ($manage_service) {
    service { 'gitea':
      ensure     => 'running',
      enable     => true,
      hasstatus  => false,
      hasrestart => false,
      provider   => $service_provider,
      subscribe  => Remote_File['gitea'],
    }
  }
}
