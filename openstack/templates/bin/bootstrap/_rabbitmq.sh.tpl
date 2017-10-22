#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

(\
    helm get rabbitmq-manager && \
    helm upgrade rabbitmq-manager {{ .Values.chart_prefix }}/rabbitmq-manager \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
) || (\
    helm install -n rabbitmq-manager {{ .Values.chart_prefix }}/rabbitmq-manager \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
)
