#!/bin/bash -xe

helm get openstack-memcached \
    || helm install /opt/openstack-helm/memcached \
        --name openstack-memcached \
        --set replicaCount=1,memcached.maxItemMemory=512
