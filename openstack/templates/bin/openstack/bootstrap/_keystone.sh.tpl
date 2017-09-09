#!/bin/bash -xe

{{- $http_protocol := .Values.openstack.http_protocol }}
{{- $region := .Values.openstack.region }}
{{- $ingress_suffix := .Values.openstack.ingress_suffix }}
{{- $admin_password := .Values.openstack.admin_password }}

source /mnt/openstack/etc/adminrc

helm get openstack-keystone \
    || helm install charts/keystone \
        --name openstack-keystone --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml

kubectl get cm keystone-etc -o jsonpath='{.data.keystone\.conf}' > /etc/keystone/keystone.conf
mkdir -p /etc/keystone/fernet-keys
kubectl get cm keystone-fernet-keys -o jsonpath='{.data.0}' > /etc/keystone/fernet-keys/0
kubectl get cm keystone-fernet-keys -o jsonpath='{.data.1}' > /etc/keystone/fernet-keys/1

echo "db_sync"
/opt/keystone/bin/keystone-manage db_sync

echo "bootstrap"
# Setup bootstrap
/opt/keystone/bin/keystone-manage bootstrap --bootstrap-password {{$admin_password}} \
  --bootstrap-public-url {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}/v3/ \
  --bootstrap-internal-url {{ $http_protocol }}://keystone-public{{ $ingress_suffix }}/v3/ \
  --bootstrap-admin-url {{ $http_protocol }}://keystone-admin{{ $ingress_suffix }}/v3/ \
  --bootstrap-region-id {{ $region }}

# Setup projects
{{range $project := .Values.openstack.projects}}
openstack project show {{$project}} || openstack project create {{$project}}
{{end}}


# Setup users
{{range $user, $user_data := .Values.openstack.user_map}}
openstack user show {{$user_data.user}} \
|| ( \
openstack user create --domain {{$user_data.domain}} --password {{$user_data.password}} {{$user_data.user}} && \
openstack role add --project {{$user_data.project}} --user {{$user_data.user}} {{$user_data.role}} \
)
{{end}}


# Setup services
{{- range $service := .Values.openstack.enable_services }}

{{- if eq $service "glance" }}
openstack service show {{ $service }} \
|| ( \
description="OpenStack Image" && \
type="image" && \
url="{{ $http_protocol }}://{{ $service }}{{ $ingress_suffix }}" && \
openstack service create --name {{ $service }} --description "$description" $type && \
openstack endpoint create --region {{ $region }} $type public   $url && \
openstack endpoint create --region {{ $region }} $type internal $url && \
openstack endpoint create --region {{ $region }} $type admin    $url \
)

{{- else if eq $service "nova" }}
openstack service show {{ $service }} \
|| ( \
description="OpenStack Compute" && \
type="compute" && \
url="{{ $http_protocol }}://{{ $service }}{{ $ingress_suffix }}/v2.1" && \
openstack service create --name {{ $service }} --description "$description" $type && \
openstack endpoint create --region {{ $region }} $type public   $url && \
openstack endpoint create --region {{ $region }} $type internal $url && \
openstack endpoint create --region {{ $region }} $type admin    $url \
)

{{- else if eq $service "neutron" }}
openstack service show {{ $service }} \
|| ( \
description="OpenStack Networking" && \
type="network" && \
url="{{ $http_protocol }}://{{ $service }}{{ $ingress_suffix }}" && \
openstack service create --name {{ $service }} --description "$description" $type && \
openstack endpoint create --region {{ $region }} $type public   $url && \
openstack endpoint create --region {{ $region }} $type internal $url && \
openstack endpoint create --region {{ $region }} $type admin    $url \
)

{{- else if eq $service "placement" }}
openstack service show {{ $service }} \
|| ( \
description="OpenStack Placement" && \
type="placement" && \
url="{{ $http_protocol }}://{{ $service }}{{ $ingress_suffix }}" && \
openstack service create --name {{ $service }} --description "$description" $type && \
openstack endpoint create --region {{ $region }} $type public   $url && \
openstack endpoint create --region {{ $region }} $type internal $url && \
openstack endpoint create --region {{ $region }} $type admin    $url \
)

{{- end }}
{{- end }}
