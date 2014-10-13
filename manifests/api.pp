class glance::api($listen='0.0.0.0',
                  $port='9292',
                  $workers=0,
                  $ssl=false,
                  $defaultstore='swift',
                  $registry_host,
                  $registry_ssl=false,
                  $memcache_servers='localhost:11211',
                  $images_tenant='glance',
                  $swift_store_region=undef) inherits glance
{

  $total_procs = 1 + $workers
  $api_flavor = hiera('glance::api::flavor', 'keystone')
  $cache_max_size = hiera('glance::api::cache_max_size', '10737418240')

  package { 'glance-api':
    ensure => installed,
    before => User['glance'],
  }

  service { 'glance-api':
    ensure => running,
  }

  if $ssl {
    File <| tag == 'sslcert' |> {
      notify +> Service['glance-api'],
    }
    $check_command = "https_port!9292"
  } else {
    $check_command = "http_port!9292"
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
      content => template("glance/${glance::openstack_version}/glance-api.conf.erb");
    '/etc/glance/glance-api-paste.ini':
      content => template("glance/${glance::openstack_version}/glance-api-paste.ini.erb");
    '/etc/glance/glance-cache.conf':
      content => template("glance/${glance::openstack_version}/glance-cache.conf.erb");
    '/etc/glance/glance-scrubber.conf':
      content => template("glance/${glance::openstack_version}/glance-scrubber.conf.erb");
    '/etc/glance/policy.json':
      source => "puppet:///modules/glance/${glance::openstack_version}/policy.json";
    '/etc/glance/schema-image.json':
      source => "puppet:///modules/glance/${glance::openstack_version}/schema-image.json";
  }

  firewall { "100 glance-api":
    dport  => 9292,
    proto  => tcp,
    action => accept,
  }

  nagios::service { "http_glance_api":
    check_command => $check_command,
    servicegroups => 'openstack-endpoints';
  }

  nagios::nrpe::service {
    'service_glance-api':
      check_command => "/usr/lib/nagios/plugins/check_procs -c ${total_procs}:${total_procs} -u glance -a /usr/bin/glance-api";
  }

  $nagios_keystone_user = hiera('nagios::keystone_user')
  $nagios_keystone_pass = hiera('nagios::keystone_pass')
  $nagios_keystone_tenant = hiera('nagios::keystone_tenant')
  $nagios_image_count = hiera('nagios::image_count')
  $nagios_image = hiera('nagios::image')

  nagios::service {
    'check_glance':
      check_command => "check_glance!${keystone_protocol}://${keystone_host}:5000/v2.0/!${nagios_keystone_user}!${nagios_keystone_pass}!${nagios_keystone_tenant}!${nagios_image_count}!${nagios_image}",
  }
}
