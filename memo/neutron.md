/etc/neutron/neutron.conf

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


---

ml2_conf.ini

[ml2]
type_drivers = local
tenant_network_types = local
mechanism_drivers = linuxbridge

[securitygroup]
enable_ipset = false


linuxbridge_agent.ini
[vxlan]
enable_vxlan = false

[securitygroup]
enable_security_group = true
firewall_driver = neutron.agent.firewall.NoopFirewallDriver


---


/etc/neutron/dhcp_agent.ini
[DEFAULT]
interface_driver = linuxbridge
dhcp_driver = neutron.agent.linux.dhcp.Dnsmasq
enable_isolated_metadata = true


---


/etc/neutron/metadata_agent.ini

[DEFAULT]
nova_metadata_ip = localhost
metadata_proxy_shared_secret = METADATA_SECRET



/opt/neutron/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini upgrade head


/opt/neutron/bin/neutron-server --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini  --config-file /etc/neutron/plugins/ml2/linuxbridge_agent.ini   --logfile /var/log/neutron-server.log > /dev/null &
/opt/neutron/bin/neutron-linuxbridge-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/plugins/ml2/linuxbridge_agent.ini  --logfile /var/log/neutron-linuxbridge-agent.log > /dev/null &
/opt/neutron/bin/neutron-dhcp-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/dhcp_agent.ini  --logfile /var/log/neutron-dhcp-agent.log > /dev/null &
/opt/neutron/bin/neutron-metadata-agent --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/plugins/ml2/ml2_conf.ini --config-file /etc/neutron/metadata_agent.ini  --logfile /var/log/neutron-metadata-agent.log > /dev/null &


