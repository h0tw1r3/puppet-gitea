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
# @param source
#   File source
#
# @param content
#   File content
#
define gitea::custom::file (
  Variant[String,Undef] $source  = undef,
  Variant[String,Undef] $content = undef,
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
    source  => $source,
    content => $content,
    owner   => $gitea::owner,
    group   => $gitea::group,
    notify  => Class['gitea::service'],
  }
}
