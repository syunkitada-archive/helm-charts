#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get values openstack > /tmp/values.yaml
helm get openstack-neutron \
    || helm install charts/neutron \
        --name openstack-neutron -f /tmp/values.yaml

kubectl get cm neutron-etc -o jsonpath='{.data.neutron\.conf}' > /etc/neutron/neutron.conf

/opt/neutron/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf upgrade head


openstack network show local-net \
  || openstack network create local-net
openstack subnet show local-subnet \
  || openstack subnet create local-subnet --network local-net --subnet-range 192.168.100.0/24
