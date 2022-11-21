# @summary creates gitea user
#
# @api private
#
# @param manage_user
#   Should we manage provisioning the user?
#
# @param manage_group
#   Should we manage provisioning the group?
#
# @param manage_home
#   Should we manage provisioning the home directory?
#
# @param owner
#   The user owning gitea
#
# @param group
#   The group owning gitea
#
# @param home
#   Qualified path to the user home directory
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
