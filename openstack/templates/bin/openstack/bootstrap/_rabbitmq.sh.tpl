#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get values openstack > /tmp/values.yaml
helm get openstack-rabbitmq \
    || helm install /opt/openstack-helm/rabbitmq \
        --name openstack-rabbitmq \
        --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass
