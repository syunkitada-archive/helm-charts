#!/bin/bash -xe

(\
    helm get openstack-horizon && \
    helm upgrade openstack-horizon {{ .Values.chart_prefix }}/horizon \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
) || (\
    helm install -n openstack-horizon {{ .Values.chart_prefix }}/horizon \
        --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml \
)
