# Class: gitea::user
# ===========================
#
# Manages user for the `::gitea` class.
#
# Parameters
# ----------
#
# @param manage_user
#  Should we manage provisioning the user? Default: true
#
# @param manage_group
#  Should we manage provisioning the group? Default: true
#
# @param manage_home
#  Should we manage provisioning the home directory? Default: true
#
# @param owner
#  The user owning gitea and its' files. Default: 'git'
#
# @param group
#  The group owning gitea and its' files. Default: 'git'
#
# @param home
#  Qualified path to the users' home directory. Default: empty
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
class gitea::user (
  Boolean $manage_user   = $gitea::manage_user,
  Boolean $manage_group  = $gitea::manage_group,
  Boolean $manage_home   = $gitea::manage_home,
  String  $owner         = $gitea::owner,
  String  $group         = $gitea::group,
  Optional[String] $home = $gitea::home,
) {
  if ($manage_home) {
    if $home == undef {
      $homedir = "/home/${owner}"
    } else {
      $homedir = $home
    }
  }

  if ($manage_user) {
    group { $group:
      ensure => present,
      system => true,
    }
  }

  if ($manage_user) {
    user { $owner:
      ensure     => present,
      gid        => $group,
      home       => $homedir,
      managehome => $manage_home,
      system     => true,
      require    => Group[$group],
    }
  }
}
