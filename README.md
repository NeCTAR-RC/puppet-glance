Puppet Glance
=============

Variables
---------

Glance

 * glance_defaultstore
 * glance_keystone_user
 * glance_keystone_password
 * glance_registry_host
 * glance_api_workers
 * glance_registry_workers
 * glance_api_ssl
 * glance_registration_ssl

Openstack

 * openstack_version

Keystone

 * keystone_service_tenant
 * keystone_host
 * keystone_protocol

SSL certs

 * ssl_cert_path - where on the filesystem the ssl cert lives
 * ssl_key_path  - where on the filesystem the ssl key lives

Note: If you tag these resources with 'sslcert' nginx will be restarted if these change.
