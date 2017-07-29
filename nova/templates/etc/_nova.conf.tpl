{{- $service_user := .Values.openstack.user_map.service }}
{{- $openstack := .Values.openstack }}
{{- $nova := .Values.openstack.service_map.nova }}
{{- $keystone := .Values.openstack.service_map.keystone }}
{{- $glance := .Values.openstack.service_map.glance }}
{{- $neutron := .Values.openstack.service_map.neutron }}
{{- $placement := .Values.openstack.service_map.placement }}
{{- $db := .Values.mysql.database_map.common }}
{{- $transport_url := .Values.rabbitmq.connection_map.common.transport_url }}

[DEFAULT]
debug = {{ $openstack.debug | default "false" }}
transport_url = {{ $transport_url }}
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
compute_driver = libvirt.LibvirtDriver
state_path = /var/lib/nova
bindir = /opt/nova/bin

[api]
auth_strategy = keystone

[keystone_authtoken]
auth_uri = {{$keystone.auth_uri}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}

[api_database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/nova_api

[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/nova

[vnc]
enabled = false
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[libvirt]
virt_type = qemu

[glance]
api_servers = {{$glance.internal_url}}

[neutron]
os_region_name = {{$keystone.region}}
url = {{$neutron.internal_url}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}
service_metadata_proxy = true
metadata_proxy_shared_secret = METADATA_SECRET

[placement]
os_region_name = {{$keystone.region}}
auth_uri = {{$keystone.auth_uri}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}
