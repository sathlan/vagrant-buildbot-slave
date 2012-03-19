class buildbot::service {
  service { 'buildbot':
    ensure => running,
    hasrestart => true,
    hasstatus  => false,
    require => Class['buildbot::install'],
  }
}
