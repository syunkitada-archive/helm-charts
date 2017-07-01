#!/bin/bash -xe

/opt/kubernetes/bin/helm get openstack-memcached \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/memcached \
        --name openstack-memcached \
        --set replicaCount=1,memcached.maxItemMemory=512
