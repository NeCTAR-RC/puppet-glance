Puppet Glance
=============

Class: glance
-------------
 * glance::keystone_user
 * glance::keystone_password

Class: glance::api
------------------
 * glance::api::ssl
 * glance::api::defaultstore
 * glance::api::registry_host
 * glance::api::registry_ssl
 * glance::api::images_tenant
 * glance::api::memcache_servers

Class: glance::registry
-----------------------
 * glance::registry::db_host
 * glance::registry::db_user
 * glance::registry::db_pass
 * glance::registry::ssl
 * glance::registry::memcache_servers

Openstack
---------
 * openstack_version

Keystone
--------
 * keystone::host
 * keystone::protocol
 * keystone::service_tenant

SSL certs
---------

 * ssl_cert_path - where on the filesystem the ssl cert lives
 * ssl_key_path  - where on the filesystem the ssl key lives

Note: If you tag these resources with 'sslcert' glance will be restarted if these change.

