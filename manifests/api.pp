class glance::api($workers, $ssl, $defaultstore, $registry_host, $registry_ssl=false) inherits glance {

  $total_procs = 1 + $workers

  package { 'glance-api':
    ensure => installed,
    before => User['glance'],
  }

  realize Package['python-keystone']

  service { 'glance-api':
    ensure => running,
  }

  if $ssl {
    File <| tag == 'sslcert' |> {
      notify +> Service['glance-api'],
    }
  }

  File {
    ensure  => present,
    owner   => glance,
    group   => glance,
    mode    => '0640',
    notify  => Service['glance-api'],
    require => Package['glance-api'],
  }

  file {
    '/etc/glance/glance-api.conf':
      content => template("glance/${openstack_version}/glance-api.conf.erb");
    '/etc/glance/glance-api-paste.ini':
      content => template("glance/${openstack_version}/glance-api-paste.ini.erb");
    '/etc/glance/glance-cache.conf':
      content => template("glance/${openstack_version}/glance-cache.conf.erb");
    '/etc/glance/glance-scrubber.conf':
      content => template("glance/${openstack_version}/glance-scrubber.conf.erb");
  }


  nagios::service { 'http_glance_api':
    check_command => 'http_port!9292',
    servicegroups => 'openstack-endpoints';
  }

  nagios::nrpe::service {
    'service_glance-api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u glance -a /usr/bin/glance-api";
  }
}
