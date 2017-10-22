#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

(\
    helm get openstack-neutron && \
    helm upgrade openstack-neutron {{ .Values.chart_prefix }}/neutron \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
) || (\
    helm install -n openstack-neutron {{ .Values.chart_prefix }}/neutron \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
)

kubectl get cm neutron-etc -o jsonpath='{.data.neutron\.conf}' > /etc/neutron/neutron.conf
transport_url=`kubectl get cm rabbitmq-svc-common -o jsonpath='{.data.transport_url}'`
sed -i "s/@transport_url/$transport_url/g" /etc/nova/nova.conf

/opt/neutron/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf upgrade head


openstack network show local-net \
  || openstack network create local-net
openstack subnet show local-subnet \
  || openstack subnet create local-subnet --network local-net --subnet-range 192.168.100.0/24
