# @summary main class includes all other classes
#
# Install Gitea, a painless self-hosted Git service.
# Review module hiera for default parameter values.
#
# @example Basic usage
#   include gitea
#
# @example Install specific version
#   class { 'gitea':
#     version  => '1.17.0',
#     checksum => 'bc4a8e1f5d5f64d4be2e50c387de08d07c062aecdba2f742c2f61c20accfcc46',
#   }
#
# @see https://gitea.io
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
# @param proxy
#   Download gitea release via specified proxy
#
# @param base_url
#   Download base URL
#
# @param version
#   Version of gitea to install
#
# @param checksum
#   Checksum for the release binary
#
# @param work_path
#   Target directory for the gitea installation
#
# @param default_configuration
#   Settings for configuring Gitea. A simple working configuration is
#   provided (see hiera). Generally this parameter should NOT be provided.
#   Instead set the custom_configuration parameter to override built-in
#   defaults.
#
# @param custom_configuration
#   Override default configuration for configuring Gitea.
#   The value is merged with the `default_configuration` parameter value.
#
# @param manage_service
#   Should we manage a service definition for Gitea?
#
# @param service_epp
#   Path to service epp template file
#
# @param tmpfile_epp
#   Path to tmpfile epp template file
#
# @param robots_txt
#   Allows to provide a http://www.robotstxt.org/ file to restrict crawling
#
# @param run_path
#   Path to service runtime path
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
  Optional[Variant[String,Hash]] $checksum,
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

  contain gitea::service::user
  contain gitea::install
  contain gitea::config

  if $manage_service {
    contain gitea::service
    Class['gitea::config']
    ~> Class['gitea::service']
    Class['gitea::install']
    ~> Class['gitea::service']
  }

  Class['gitea::service::user']
  -> Class['gitea::install']
  -> Class['gitea::config']
}
