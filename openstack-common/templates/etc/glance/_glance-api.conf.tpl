{{$service_user := .Values.openstack.user_map.service}}
{{$keystone := .Values.openstack.service_map.keystone}}
{{$db := .Values.openstack.database_map.common}}
[DEFAULT]
debug = true
workers = 2
registry_host = glance-registry
registry_port = 9191

enable_v1_api = False
enable_v2_api = True

[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/glance

[keystone_authtoken]
auth_uri = {{$keystone.auth_uri}}
auth_url = {{$keystone.auth_url}}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{$service_user.project}}
username = {{$service_user.user}}
password = {{$service_user.password}}

[paste_deploy]
flavor = keystone

[glance_store]
stores = file
default_store = file
filesystem_store_datadir = /var/lib/glance/images/
