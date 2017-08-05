#!/bin/bash -xe

helm get openstack-ingress \
    || helm install charts/ingress \
        --name openstack-ingress
