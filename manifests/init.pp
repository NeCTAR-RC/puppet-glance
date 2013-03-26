class glance {

  $keystone_host = hiera('keystone::host')
  $keystone_protocol = hiera('keystone::protocol')
  $keystone_service_tenant = hiera('keystone::service_tenant')
  $keystone_user = hiera('glance::keystone_user')
  $keystone_password = hiera('glance::keystone_password')

  user { 'glance':
    groups => $ssl_group,
  }
  
}

class glance::nagios-checks {
  # These are checks that can be run by the nagios server.
  nagios::command {
    'check_glance':
      check_command => '/usr/lib/nagios/plugins/check_glance.py --auth_url \'$ARG1$\' --username \'$ARG2$\' --password \'$ARG3$\' --tenant \'$ARG4$\' --req_count \'$ARG5$\' --req_images \'$ARG6$\''
  }
}

