#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/kubernetes/bin/helm get openstack-horizon \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/horizon \
        --name openstack-horizon
