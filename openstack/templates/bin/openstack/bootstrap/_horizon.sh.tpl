#!/bin/bash -xe

helm get openstack-horizon \
    || helm install /opt/openstack-helm/horizon \
        --name openstack-horizon
