# @summary gitea custom file
#
# Manage files in the Gitea `CustomPath` folder
#
# @see https://docs.gitea.io/en-us/customizing-gitea/
#
# @example custom css
#   gitea::custom::file { 'public/css/custom.css':
#     content => file('profile/gitea/custom.css'),
#   }
#
# @example custom logo
#   gitea::custom::file { 'public/img/logo.svg':
#     source => 'puppet:///modules/profile/gitea/logo.svg',
#   }
#
# @param ensure
#   Passed to File resource
#
# @param source
#   Passed to File resource
#
# @param content
#   Passed to File resource
#
# @param recurse
#   Passed to File resource
#
define gitea::custom::file (
  Optional[Variant[String,Boolean]] $ensure  = undef,
  Variant[String,Undef]             $source  = undef,
  Variant[String,Undef]             $content = undef,
  Variant[Boolean,Enum['remote']]   $recurse = false,
) {
  require gitea::config

  $custom_path = "${gitea::work_path}/custom/"

  extlib::dir_split(dirname("${custom_path}${title}")).each |$path| {
    if $path.length > $custom_path.length {
      unless defined(File[$path]) {
        file { $path:
          ensure => directory,
          owner  => $gitea::owner,
          group  => $gitea::group,
        }
      }
    }
  }

  file { "${custom_path}${title}":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    owner   => $gitea::owner,
    group   => $gitea::group,
    recurse => $recurse,
    notify  => Class['gitea::service'],
  }
}
