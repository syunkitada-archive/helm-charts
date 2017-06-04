[DEFAULT]
core_plugin = ml2
service_plugins =
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true
transport_url = rabbit://openstack:openstackpass@localhost:5672

[database]
connection = mysql+pymysql://root:rootpass@localhost/neutron

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

[nova]
auth_url = http://localhost:35357
auth_type = password
project_domain_name = default
user_domain_name = default
region_name = RegionOne
project_name = service
username = openstack
password = openstackpass
