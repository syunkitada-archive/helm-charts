#!/bin/bash -xe

helm get openstack-compute \
    || helm install /opt/openstack-helm/compute \
        --name openstack-compute
