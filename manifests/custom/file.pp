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
  Optional[Enum['file','absent']] $ensure  = undef,
  Variant[String,Undef]           $source  = undef,
  Variant[String,Undef]           $content = undef,
  Variant[Boolean,Enum['remote']] $recurse = false,
) {
  if $ensure != 'absent' and $source.empty and $content.empty {
    fail("gitea::custom::file[${name}] source or content required")
  }

  $owner = getvar('gitea.owner', lookup('gitea::owner'))
  $group = getvar('gitea.owner', lookup('gitea::group'))
  $custom_path = sprintf('%s/custom/', getvar('gitea.work_path', lookup('gitea::work_path')))

  if $ensure != 'absent' {
    extlib::dir_split(dirname("${custom_path}${title}")).each |$path| {
      if $path.length > $custom_path.length {
        unless defined(File[$path]) {
          ensure_resource('file', $path, {
              ensure => directory,
              owner  => $owner,
              group  => $group,
          })
        }
      }
    }
  }

  file { "${custom_path}${title}":
    ensure  => $ensure,
    source  => $source,
    content => $content,
    owner   => $owner,
    group   => $group,
    recurse => $recurse,
  }
}
