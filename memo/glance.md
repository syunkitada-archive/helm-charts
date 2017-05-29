

[DEFAULT]
workers = 1

[database]
connection = mysql+pymysql://root:rootpass@localhost/glance

[keystone_authtoken]
auth_uri = http://localhost:5000
auth_url = http://localhost:35357
memcached_servers = localhost:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = openstack
password = openstackpass

[paste_deploy]
flavor = keystone

[glance_store]
stores = file,http
default_store = file
filesystem_store_datadir = /var/lib/glance/images/




----

[DEFAULT]
workers = 1

[database]
connection = mysql+pymysql://root:rootpass@localhost/glance

[keystone_authtoken]
auth_uri = http://localhost:5000
auth_url = http://localhost:35357
memcached_servers = localhost:11211
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = service
username = openstack
password = openstackpass

[paste_deploy]
flavor = keystone


---



mkdir -p /var/lib/glance/images/
/opt/glance/bin/glance-manage db_sync


/opt/glance/bin/glance-api --config-file /etc/glance/glance-api.conf --logfile /var/log/glance-api.log > /dev/null &
/opt/glance/bin/glance-registry --config-file /etc/glance/glance-registry.conf --logfile /var/log/glance-registry.log > /dev/null &


/opt/glance/bin/pip install python-memcached




