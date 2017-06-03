#!/bin/sh -xe

# Setup db
mysql -u{{.Values.openstack.database.user}} -p{{.Values.openstack.database.password}} -e 'CREATE DTABASE IF NOT EXISTS keystone'
/opt/keystone/bin/keystone-manage db_sync

# Setup bootstrap
/opt/keystone/bin/keystone-manage bootstrap --bootstrap-password {{.Values.openstack.service_map.admin_password}} \
  --bootstrap-admin-url {{.Values.openstack.service_map.admin_url}} \
  --bootstrap-internal-url {{.Values.openstack.service_map.internal_url}} \
  --bootstrap-public-url {{.Values.openstack.service_map.public_url}} \
  --bootstrap-region-id {{.Values.openstack.service_map.region}}
