# @summary creates gitea service user
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
# @param user
#   The user of gitea service
#
# @param group
#   The group of gitea service
#
# @param home
#   Qualified path to the user home directory
#
class gitea::service::user (
  Boolean $manage_user   = $gitea::manage_user,
  Boolean $manage_group  = $gitea::manage_group,
  Boolean $manage_home   = $gitea::manage_home,
  String  $user          = $gitea::owner,
  String  $group         = $gitea::group,
  Optional[String] $home = $gitea::home,
) {
  $homedir = ($home =~ Undef) ? {
    true  => "/home/${user}",
    false => $home,
  }

  if ($manage_group) {
    group { $group:
      ensure => present,
      system => true,
    }
  }

  if ($manage_user) {
    user { $user:
      ensure     => present,
      gid        => $group,
      home       => $homedir,
      managehome => $manage_home,
      system     => true,
      require    => Group[$group],
    }
  }
}
