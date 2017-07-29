#!/bin/bash -xe

helm get openstack-ingress \
    || helm install /opt/openstack-helm/ingress \
        --name openstack-ingress
