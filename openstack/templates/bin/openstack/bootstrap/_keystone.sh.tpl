#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$glance := .Values.openstack.service_map.glance}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/kubernetes/bin/helm get openstack-keystone \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/keystone \
        --name openstack-keystone \

echo "db_sync"
/opt/keystone/bin/keystone-manage db_sync

echo "bootstrap"
# Setup bootstrap
/opt/keystone/bin/keystone-manage bootstrap --bootstrap-password {{$admin_password}} \
  --bootstrap-admin-url {{$keystone.admin_url}} \
  --bootstrap-internal-url {{$keystone.internal_url}} \
  --bootstrap-public-url {{$keystone.public_url}} \
  --bootstrap-region-id {{$keystone.region}}


source /etc/openstack/adminrc

# Setup projects
{{range $project := .Values.openstack.projects}}
openstack project show {{$project}} || openstack project create {{$project}}
{{end}}


# Setup users
{{range $user, $user_data := .Values.openstack.user_map}}
openstack user show openstack \
|| ( \
openstack user create --domain {{$user_data.domain}} --password {{$user_data.password}} {{$user_data.user}} && \
openstack role add --project {{$user_data.project}} --user {{$user_data.user}} {{$user_data.role}} \
)
{{end}}


# Setup services
{{range $service, $service_data := .Values.openstack.service_map}}
{{if or (ne $service "keystone") $service_data.enable}}
openstack service show {{$service}} \
|| ( \
openstack service create --name {{$service}} --description "{{$service_data.description}}" {{$service_data.type}} && \
openstack endpoint create --region {{$service_data.region}} {{$service_data.type}} public   {{$service_data.public_url}} && \
openstack endpoint create --region {{$service_data.region}} {{$service_data.type}} internal {{$service_data.internal_url}} && \
openstack endpoint create --region {{$service_data.region}} {{$service_data.type}} admin    {{$service_data.admin_url}} \
)
{{end}}
{{end}}
