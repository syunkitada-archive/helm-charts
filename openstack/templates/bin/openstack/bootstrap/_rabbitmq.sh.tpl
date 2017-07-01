#!/bin/bash -xe

/opt/kubernetes/bin/helm get openstack-rabbitmq \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/rabbitmq \
        --name openstack-rabbitmq \
        --set persistence.enabled=false,rabbitmqUsername=openstack,rabbitmqPassword=openstackpass
