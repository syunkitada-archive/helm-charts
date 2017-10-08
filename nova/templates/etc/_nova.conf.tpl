{{- $http_protocol := .Values.openstack.http_protocol }}
{{- $ingress_suffix := .Values.openstack.ingress_suffix }}
{{- $service_user := .Values.openstack.user_map.service }}
{{- $openstack := .Values.openstack }}
{{- $db := .Values.mysql.database_map.common }}

[DEFAULT]
debug = {{ $openstack.debug | default "false" }}
transport_url = @transport_url
use_neutron = True
firewall_driver = nova.virt.firewall.NoopFirewallDriver
compute_driver = libvirt.LibvirtDriver
state_path = /var/lib/nova
bindir = /opt/nova/bin


[api]
auth_strategy = keystone


[keystone_authtoken]
auth_uri = {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}
auth_url = {{ $http_protocol }}://keystone-admin{{ $ingress_suffix }}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{ $service_user.project }}
username = {{ $service_user.user }}
password = {{ $service_user.password }}


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
api_servers = {{ $http_protocol }}://glance{{ $ingress_suffix }}


[neutron]
os_region_name = {{ $openstack.region }}
url = {{ $http_protocol }}://neutron{{ $ingress_suffix }}
auth_uri = {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}
auth_url = {{ $http_protocol }}://keystone-admin{{ $ingress_suffix }}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{ $service_user.project }}
username = {{ $service_user.user }}
password = {{ $service_user.password }}
service_metadata_proxy = true
metadata_proxy_shared_secret = METADATA_SECRET


[placement]
os_region_name = {{ $openstack.region }}
auth_uri = {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}
auth_url = {{ $http_protocol }}://keystone-admin{{ $ingress_suffix }}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{ $service_user.project }}
username = {{ $service_user.user }}
password = {{ $service_user.password }}
