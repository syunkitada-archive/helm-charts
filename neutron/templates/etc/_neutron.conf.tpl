{{- $service_user := .Values.openstack.user_map.service }}
{{- $keystone := .Values.openstack.service_map.keystone }}
{{- $db := .Values.mysql.database_map.common }}
{{- $transport_url := .Values.rabbitmq.connection_map.common.transport_url }}

[DEFAULT]
debug = true
core_plugin = ml2
service_plugins =
auth_strategy = keystone
notify_nova_on_port_status_changes = true
notify_nova_on_port_data_changes = true
transport_url = {{ $transport_url }}

api_workers = 2
rpc_workers = 1


[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/neutron


[agent]
root_helper =


[keystone_authtoken]
auth_uri = {{$keystone.auth_uri}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}


[nova]
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}
