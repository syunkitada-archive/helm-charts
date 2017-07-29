#!/bin/bash -xe

helm get values openstack > /tmp/values.yaml
helm get openstack-rabbitmq \
    || helm install /opt/openstack-helm/rabbitmq \
        --name openstack-rabbitmq \
        --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass
