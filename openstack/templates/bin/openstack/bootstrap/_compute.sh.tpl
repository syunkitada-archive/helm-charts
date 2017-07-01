#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/kubernetes/bin/helm get openstack-compute \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/compute \
        --name openstack-compute
