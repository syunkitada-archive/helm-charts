{{$keystone := .Values.openstack.service_map.keystone}}
export OS_USERNAME=admin
export OS_PASSWORD={{.Values.openstack.admin_password}}
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL={{$keystone.admin_url}}
export OS_IDENTITY_API_VERSION=3
