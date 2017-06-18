#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$glance := .Values.openstack.service_map.glance}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/glance/bin/glance-manage db_sync


source /etc/openstack/adminrc

cd /tmp/
curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public
