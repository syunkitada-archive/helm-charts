[ml2]
type_drivers = local,flat,vlan
tenant_network_types = local
mechanism_drivers = linuxbridge
extension_drivers = 

[ml2_type_flat]
flat_networks = test-provider

[securitygroup]
enable_ipset = false
enable_security_group = true
