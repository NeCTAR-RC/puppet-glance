class glance::develop($branch='stable/juno') inherits glance {

  include memcached

  file {['/etc/glance', '/var/log/glance', '/var/lib/glance']:
    ensure => directory,
    owner  => glance,
    group  => glance,
  }
  
  User['glance'] {
    home => '/var/lib/glance',
  }
  
  git::clone { 'glance':
    git_repo        => 'https://github.com/openstack/glance.git',
    projectroot     => '/opt/glance',
    branch          => $branch,
  }
  
  include glance::develop::api
  include glance::develop::registry

}

class glance::develop::api inherits glance::api {
  Package['glance-api'] {
    ensure => absent,
  }
  Service['glance-api'] {
    provider => upstart,
  }

  file {'/etc/init/glance-api.conf':
    source => 'puppet:///modules/glance/api-init.conf',
  }

}

class glance::develop::registry inherits glance::registry {
  Package['glance-registry'] {
    ensure => absent,
  }
  
  Service['glance-registry'] {
    provider => upstart,
  }
  
  file {'/etc/init/glance-registry.conf':
    source => 'puppet:///modules/glance/registry-init.conf',
  }

}
