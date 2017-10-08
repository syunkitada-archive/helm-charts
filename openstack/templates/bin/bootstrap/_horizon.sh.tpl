#!/bin/bash -xe

helm get openstack-horizon \
    || helm install {{ .Values.chart_prefix }}/horizon \
        --name openstack-horizon --namespace {{ .Release.Namespace }} -f /mnt/openstack/etc/values.yaml
