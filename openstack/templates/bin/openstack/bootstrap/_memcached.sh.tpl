#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get openstack-memcached \
    || helm install charts/memcached \
        --name openstack-memcached --namespace {{ .Release.Namespace }} \
        --set replicaCount=1,memcached.maxItemMemory=512
