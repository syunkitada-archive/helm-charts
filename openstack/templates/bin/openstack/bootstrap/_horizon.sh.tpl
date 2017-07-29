#!/bin/bash -xe

helm get values openstack > /tmp/values.yaml
helm get openstack-horizon \
    || helm install /opt/openstack-helm/horizon \
        --name openstack-horizon -f /tmp/values.yaml
