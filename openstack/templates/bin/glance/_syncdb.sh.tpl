#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$glance := .Values.openstack.service_map.glance}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/glance/bin/glance-manage db_sync
