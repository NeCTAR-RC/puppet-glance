class glance::registry inherits glance {

  if !$::glance_registry_workers {
    $workers = 1
    } else {
    $workers = $::glance_registry_workers
  }

  $total_procs = 1 + $workers

  package { 'glance-registry':
    ensure => installed,
    before => User['glance'],
  }

  realize Package['python-mysqldb']
  realize Package['python-keystone']

  service { 'glance-registry':
    ensure => running,
  }

  file { '/etc/glance/glance-registry.conf':
    ensure  => present,
    owner   => glance,
    group   => glance,
    mode    => '0640',
    content => template("glance/glance-registry.conf-${::openstack_version}.erb"),
    notify  => Service['glance-registry'],
    require => Package['glance-registry'],
  }

  file { '/etc/glance/glance-registry-paste.ini':
    ensure  => present,
    owner   => glance,
    group   => glance,
    mode    => '0640',
    content => template('glance/glance-registry-paste.ini.erb'),
    notify  => Service['glance-registry'],
    require => Package['glance-registry'],
  }

  if $::glance_registry_ssl {
    File <| tag == 'sslcert' |> {
      notify +> Service['glance-registry'],
    }
  }

  nagios::service { 'http_glance_registry':
    check_command => 'https_port!9191',
    servicegroups => 'openstack-endpoints';
  }

  nagios::nrpe::service {
    'service_glance-registry':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers}:${total_procs} -u glance -a /usr/bin/glance-registry";
  }
}
