#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get values openstack > /tmp/values.yaml
helm get openstack-rabbitmq \
    || helm install charts/rabbitmq \
        --name openstack-rabbitmq --namespace {{ .Release.Namespace }} \
        --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass
