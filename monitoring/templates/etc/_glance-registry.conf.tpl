{{- $http_protocol := .Values.openstack.http_protocol }}
{{- $ingress_suffix := .Values.openstack.ingress_suffix }}
{{- $db := .Values.mysql.database_map.common }}
{{- $service_user := .Values.openstack.user_map.service }}
[DEFAULT]
debug = {{ .Values.openstack.debug | default "false" }}
workers = 2


[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/glance


[keystone_authtoken]
auth_uri = {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}
auth_url = {{ $http_protocol }}://keystone-admin{{ $ingress_suffix }}
auth_type = password
project_domain_name = default
user_domain_name = default
project_name = {{ $service_user.project }}
username = {{ $service_user.user }}
password = {{ $service_user.password }}


[paste_deploy]
flavor = keystone
