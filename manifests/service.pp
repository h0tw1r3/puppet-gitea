# Class: gitea::service
# ===========================
#
# Manages services for the `::gitea` class.
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
class gitea::service {
  service { 'gitea':
    ensure     => running,
    enable     => true,
    hasstatus  => false,
    hasrestart => false,
    require    => Class['gitea::install'],
  }
}
