#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get openstack-memcached \
    || helm install {{ .Values.chart_prefix }}/memcached \
        --name openstack-memcached --namespace {{ .Release.Namespace }} \
        --set replicaCount=1,memcached.maxItemMemory=512 \
        -f /mnt/openstack/etc/values.yaml
