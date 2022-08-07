# gitea custom file
#
# Parameters
# ----------
#
# @param source
#  optional file source
#
# @param content
#  optional file content
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
