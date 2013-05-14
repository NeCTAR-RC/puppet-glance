class glance::registry($listen='0.0.0.0',
                       $port=9191,
                       $workers=0,
                       $ssl=false,
                       $db_user,
                       $db_pass,
                       $db_host,
                       $memcache_servers='localhost:11211') inherits glance
{

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

  if $ssl {
    File <| tag == 'sslcert' |> {
      notify +> Service['glance-registry'],
    }
  }

  nagios::service { 'http_glance_registry':
    check_command => 'check_glance_registry_ssl!9191',
    servicegroups => 'openstack-endpoints';
  }

  nagios::nrpe::service {
    'service_glance-registry':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${workers}:${total_procs} -u glance -a /usr/bin/glance-registry";
  }
}

class glance::registry::nagios-checks {
  # These are checks that can be run by the nagios server.
  nagios::command {
    'check_glance_registry_ssl':
      check_command => '/usr/lib/nagios/plugins/check_http --ssl -p \'$ARG1$\' -e 401 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
    'check_glance_registry':
      check_command => '/usr/lib/nagios/plugins/check_http -p \'$ARG1$\' -e 401 -H \'$HOSTADDRESS$\' -I \'$HOSTADDRESS$\'';
  }
}
