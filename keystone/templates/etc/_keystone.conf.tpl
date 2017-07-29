{{- $openstack := .Values.openstack }}
{{- $db := .Values.mysql.database_map.common }}
[DEFAULT]
debug = {{ .Values.openstack.debug | default "false" }}

[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/keystone

[token]
provider = {{ $openstack.keystone.token.provider | default "fernet" }}
