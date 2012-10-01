class glance::registry inherits glance {

  if !$::glance_registry_workers {
    $workers = 0
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
    content => template("glance/${openstack_version}/glance-registry.conf.erb"),
    notify  => Service['glance-registry'],
    require => Package['glance-registry'],
  }

  file { '/etc/glance/glance-registry-paste.ini':
    ensure  => present,
    owner   => glance,
    group   => glance,
    mode    => '0640',
    content => template("glance/${openstack_version}/glance-registry-paste.ini.erb"),
    notify  => Service['glance-registry'],
    require => Package['glance-registry'],
  }

  if $::glance_registry_ssl {
    File <| tag == 'sslcert' |> {
      notify +> Service['glance-registry'],
    }
  }

  nagios::nrpe::service {
    'service_glance-registry':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers}:${total_procs} -u glance -a /usr/bin/glance-registry";
  }
}
