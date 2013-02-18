puppet-glance
=============

Variables
---------

 * environment 
 * glance_api_ssl 
 * glance_db_host 
 * glance_db_pass 
 * glance_db_user 
 * glance_defaultstore 
 * glance_images_tenant - The tenant under which images are stored if using swift
 * glance_keystone_password 
 * glance_keystone_user 
 * glance_memcache_servers 
 * glance_registry_host 
 * glance_registry_ssl 
 * logdebug 

Keystone

 * keystone_host 
 * keystone_protocol 
 * keystone_service_tenant 

Openstack

 * openstack_version

SSL certs

 * ssl_cacert_path 
 * ssl_certcombined_path 
 * ssl_cert_path - where on the filesystem the ssl cert lives
 * ssl_key_path  - where on the filesystem the ssl key lives

Note: If you tag these resources with 'sslcert' glance will be restarted if these change.

Classes
-------

glance::api

glance::registry
