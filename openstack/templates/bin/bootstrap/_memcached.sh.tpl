#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

(\
    helm get openstack-memcached && \
    helm upgrade openstack-memcached {{ .Values.chart_prefix }}/memcached \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
        --set replicaCount=1,memcached.maxItemMemory=512 \
) || (\
    helm install -n openstack-memcached {{ .Values.chart_prefix }}/memcached \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
        --set replicaCount=1,memcached.maxItemMemory=512 \
)
