# @summary manage service state
#
# @api private
#
class gitea::service {
  service { 'gitea':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => false,
    require    => Class['gitea::install'],
  }
}
