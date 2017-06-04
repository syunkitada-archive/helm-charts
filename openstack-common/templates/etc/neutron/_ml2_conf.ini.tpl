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
