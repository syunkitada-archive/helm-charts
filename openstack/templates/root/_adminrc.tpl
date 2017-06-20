{{$keystone := .Values.openstack.service_map.keystone}}
export OS_USERNAME=admin
export OS_PASSWORD={{.Values.openstack.admin_password}}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL={{$keystone.admin_url}}
export OS_IDENTITY_API_VERSION=3


{{range $database, $database_data := .Values.openstack.database_map}}
{{range $dbname := $database_data.dbs}}
alias mysql-{{$dbname}}="mysql -h{{$database_data.host}} -P{{$database_data.port}} -u{{$database_data.user}} -p{{$database_data.password}} {{$dbname}}"
{{end}}
{{end}}
