# Class: gitea
# ===========================
#
# Manages a Gitea installation on various Linux/BSD operating systems.
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
# @param proxy
#  Download via specified proxy. Default: empty
#
# @param base_url
#  Download base URL. Default: Github. Can be used for local mirrors.
#
# @param version
#  Version of gitea to install. Default: '1.1.0'
#
# @param checksum
#  Checksum for the binary.
#
# @param work_path
#  Target directory to hold the gitea installation. Default: '/opt/gitea'
#
# @param default_configuration
#  INI style settings for configuring Gitea, may be overridden by custom_configuration.
#
# @param custom_configuration
#  INI style settings for configuring Gitea.
#
# @param manage_service
#  Should we manage a service definition for Gitea?
#
# @param service_epp
#  Path to service epp template file.
#
# @param tmpfile_epp
#  Path to tmpfile epp template file.
#
# @param robots_txt
#  Allows to provide a http://www.robotstxt.org/ file to restrict crawling.
#
# @param run_path
#  Path to service runtime path. Default: '/run/gitea'
#
# Examples
# --------
#
# @example
#    class { 'gitea':
#    }
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
class gitea (
  Boolean $manage_user,
  Boolean $manage_group,
  Boolean $manage_home,
  String $owner,
  String $group,
  Optional[String] $home,

  Optional[String] $proxy,
  String $base_url,
  String $version,
  String $checksum,
  String $work_path,

  Hash $custom_configuration,
  Hash $default_configuration,

  Boolean $manage_service,
  String $service_epp,
  String $tmpfile_epp,
  String $run_path,

  String $robots_txt,
) {
  $base_configuration = {
    '' => {
      'RUN_USER' => $owner,
    },
  }

  $configuration = deep_merge(
    deep_merge($base_configuration, $default_configuration),
  $custom_configuration)

  contain gitea::user
  contain gitea::install
  contain gitea::config

  if $manage_service {
    contain gitea::service
    Class['gitea::config']
    ~> Class['gitea::service']
    Class['gitea::install']
    ~> Class['gitea::service']
  }

  Class['gitea::user']
  -> Class['gitea::install']
  -> Class['gitea::config']
}
