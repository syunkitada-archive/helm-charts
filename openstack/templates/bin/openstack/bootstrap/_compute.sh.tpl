#!/bin/bash -xe


helm get values openstack > /tmp/values.yaml
helm get openstack-compute \
    || helm install /opt/openstack-helm/compute \
        --name openstack-compute -f /tmp/values.yaml
