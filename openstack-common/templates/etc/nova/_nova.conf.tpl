{{- $service_user := .Values.openstack.user_map.service}}
{{- $keystone := .Values.openstack.service_map.keystone}}
{{- $glance := .Values.openstack.service_map.glance}}
{{- $neutron := .Values.openstack.service_map.neutron}}
{{- $placement := .Values.openstack.service_map.placement}}
{{- $db := .Values.openstack.database_map.common}}
{{- $rpc := .Values.openstack.rpc_map.common}}

[DEFAULT]
debug = false
transport_url = rabbit://{{$rpc.user}}:{{$rpc.password}}@{{$rpc.host}}:{{$rpc.port}}{{$rpc.vhost}}
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
compute_driver = libvirt.LibvirtDriver

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
enabled = true
vncserver_listen = $my_ip
vncserver_proxyclient_address = $my_ip

[oslo_concurrency]
lock_path = /var/lib/nova/tmp

[libvirt]
virt_type = qemu

[glance]
api_servers = {{$glance.internal_url}}

[neutron]
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
auth_uri = {{$keystone.auth_uri}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}
