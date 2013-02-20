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

