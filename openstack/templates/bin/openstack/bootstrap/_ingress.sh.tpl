#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/kubernetes/bin/helm get openstack-ingress \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/ingress \
        --name openstack-ingress
