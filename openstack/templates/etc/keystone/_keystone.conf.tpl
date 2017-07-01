{{- $db := .Values.mysql.database_map.common }}
[DEFAULT]
debug = {{.Values.keystone.default.debug | default "false"}}

[database]
connection = mysql+pymysql://{{$db.user}}:{{$db.password}}@{{$db.host}}:{{$db.port}}/keystone

[token]
provider = {{.Values.keystone.token.provider}}
