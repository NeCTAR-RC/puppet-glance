class glance::api inherits glance {

  if !$::glance_api_workers {
    $workers = 1
    } else {
    $workers = $::glance_api_workers
  }

  $total_procs = 1 + $workers

  package { 'glance-api':
    ensure => installed,
    before => User['glance'],
  }

  package { 'python-swift':
    ensure => installed,
  }

  realize Package['python-keystone']

  service { 'glance-api':
    ensure => running,
  }

  if $glance_api_ssl {
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
      content => template("glance/glance-api.conf-${openstack_version}.erb");
    '/etc/glance/glance-api-paste.ini':
      content => template('glance/glance-api-paste.ini.erb');
    '/etc/glance/glance-cache.conf':
      content => template("glance/glance-cache.conf.erb");
    '/etc/glance/glance-cache-paste.ini':
      content => template('glance/glance-cache-paste.ini.erb');
    '/etc/glance/glance-scrubber.conf':
      content => template("glance/glance-scrubber.conf.erb");
    '/etc/glance/glance-scrubber-paste.ini':
      content => template('glance/glance-scrubber-paste.ini.erb');
  }

  nagios::nrpe::service {
    'service_glance-api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u glance -a /usr/bin/glance-api";
  }
}
