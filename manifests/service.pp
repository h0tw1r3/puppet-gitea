# @summary manage service state
#
# @api private
#
class gitea::service {
  # Workaround Debian systemd tmp permissions bug
  Exec <| title == 'systemd-tmpfiles' |> {
    returns => [0,73]
  }

  systemd::tmpfile { 'gitea.conf':
    content => epp($gitea::tmpfile_epp, {
        user     => $gitea::owner,
        group    => $gitea::group,
        run_path => $gitea::run_path,
    }),
  }
  -> systemd::unit_file { 'gitea.service':
    enable  => true,
    active  => true,
    content => epp($gitea::service_epp, {
        user      => $gitea::owner,
        group     => $gitea::group,
        run_path  => $gitea::run_path,
        work_path => $gitea::work_path,
    }),
    require => Class['gitea::config'],
  }
}
