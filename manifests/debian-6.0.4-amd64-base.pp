package { 'ruby1.9.1':
  ensure => present,
  before => Exec['setup-ruby19'],
}

package { 'ruby1.9.1-dev':
  ensure => present,
  before => Exec['setup-ruby19'],
}

package { 'ri1.9.1':
  ensure => present,
  before => Exec['setup-ruby19'],
}

exec { 'setup-ruby19':
  command => '[ -L /usr/bin/gem ] || mv /usr/bin/gem /usr/bin/gem1.8;
      update-alternatives --install /usr/bin/ruby ruby /usr/bin/ruby1.9.1 500 \
           --slave   /usr/share/man/man1/ruby.1.gz ruby.1.gz /usr/share/man/man1/ruby1.9.1.1.gz \
           --slave   /usr/share/man/man1/ri.1.gz ri.1.gz /usr/share/man/man1/ri1.9.1.1.gz \
           --slave   /usr/share/man/man1/rdoc.1.gz rdoc.1.gz /usr/share/man/man1/rdoc1.9.1.1.gz \
           --slave   /usr/share/man/man1/irb.1.gz irb.1.gz /usr/share/man/man1/irb1.9.1.1.gz \
           --slave   /usr/bin/ri ri /usr/bin/ri1.9.1 \
           --slave   /usr/bin/irb irb /usr/bin/irb1.9.1 \
           --slave   /usr/bin/gem gem /usr/bin/gem1.9.1 \
           --slave   /usr/bin/rdoc rdoc /usr/bin/rdoc1.9.1;
      env REALLY_GEM_UPDATE_SYSTEM=1 gem1.9.1 update --system;',
  path   => ['/usr/bin', '/bin'],
  unless => '[ -e /etc/alternatives/ruby ] && file /etc/alternatives/ruby | grep -q "1\.9"',
  before => Exec['install-bundler'],
}

package { 'git-core':
  ensure => present,
}

package { 'buildbot':
  ensure => present,
}

file {
  '/home/bbslave/':
    ensure => directory,
    group  => 'bbslave',
    mode   => 0755,
    owner  => 'bbslave';
  '/home/bbslave/buildbot':
    ensure => directory,
    group  => 'bbslave',
    mode   => 0755,
    owner  => 'bbslave';
  '/home/bbslave/buildbot/buildbot.tac':
    ensure  => file,
    content => template('/tmp/vagrant-puppet/manifests/buildbot/buildbot.tac.erb'),
    group   => 'bbslave',
    owner   => 'bbslave',
    mode    => 0644,
    require => Package['buildbot'];
  '/etc/default/buildbot':
    ensure  => file,
    source  => '/tmp/vagrant-puppet/manifests/buildbot/default',
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    require => Package['buildbot'],
    notify  => Service['buildbot'];
  '/etc/init.d/vboxload':
    ensure  => file,
    source  => '/tmp/vagrant-puppet/manifests/etc/vboxload',
    owner   => 'root',
    group   => 'root',
    mode    => 755;
  '/home/bbslave/buildbot/info/admin':
    ensure  => file,
    content => "Sofer Athlan sofer.athlan@enovance.com\n",
    owner   => 'bbslave',
    group   => 'bbslave',
    mode    => 755,
    notify  => Service['buildbot'],
    require => User['bbslave'];
  '/home/bbslave/buildbot/info/host':
    ensure  => file,
    content => "VBox based on Debian 6.  Can run tests with VBox Creation.\n",
    owner   => 'bbslave',
    group   => 'bbslave',
    mode    => 755,
    notify  => Service['buildbot'],
    require => User['bbslave'];
}

package { 'at': ensure => present }

exec { 'unload_vbox':
  command => 'echo "/etc/init.d/vboxload stop" | at "now + 1min"',
  require => [ Package['at'], File['/etc/init.d/vboxload'] ],
  path    => ['/bin', '/usr/bin' ],
  unless  => '[ -e /root/disable_unload ]'
}

service { 'buildbot':
  ensure => running,
  hasrestart => true,
  hasstatus  => false,
  require => Package['buildbot'],
}

package { 'make':
  ensure => present,
}

package { 'emacs23-nox':
  ensure => present,
}

package { 'vim':
  ensure => present,
}

host { 'debian-6':
  ip     => '127.0.0.1',
  name   => 'debian-6',
  ensure => present,
}

group { 'puppet':
  ensure => present,
}

# group bbslave is automatically created on debian.
user { 'bbslave':
  comment => 'buildbot user',
  ensure  => present,
  home    => '/home/bbslave',
  managehome => true,
  name    => 'bbslave',
  groups  => ['bbslave', 'sudo'],
}

# augeas { 'apply_puppet':
#   context => "/files/home/vagrant/.bashrc",
#   changes => "set alias puppet_apply='cd /tmp/vagrant-puppet/manifests && sudo puppet apply /tmp/vagrant-puppet/manifests/debian-6.0.4-amd64-base.pp'",
# }


exec { 'install-bundler':
  command => 'gem install bundler -v 1.0.22',
  path => ["/usr/bin", '/bin'],
  unless => 'gem list -l bundler | grep -q "bundler "'
}

package { 'augeas-tools':
  ensure => present,
}
package { 'libaugeas-ruby1.9.1':
  ensure => present,
#  before => Augeas['change_umask'],
}

package { 'libaugeas-ruby1.8':
  ensure => present,
#  before => Augeas['change_umask'],
}

#augeas { 'change_umask':
#  context => '/files/etc/login.defs',
#  changes => 'set UMASK 0002',
#  before  => Exec['install-bundler'],
#}

# exec { 'rvm':
#   command => 'bash -s stable < <(curl -s https://raw.github.com/wayneeseguin/rvm/master/binscripts/rvm-installer)',
#   path => ["/usr/bin"],
# }
