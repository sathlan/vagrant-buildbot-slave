class buildbot::install {
  package { 'git-core':
    ensure => present,
  }
  package { 'buildbot':
    ensure => present,
  }

  # group bbslave is automatically created on debian.
  user { "$user":
    comment => 'buildbot user',
    ensure  => present,
    home    => '/home/"$user"',
    managehome => true,
    name    => "$user",
    groups  => ["$user", 'sudo'],
  }
}
