#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get openstack-memcached \
    || helm install /opt/openstack-helm/memcached \
        --name openstack-memcached \
        --set replicaCount=1,memcached.maxItemMemory=512
