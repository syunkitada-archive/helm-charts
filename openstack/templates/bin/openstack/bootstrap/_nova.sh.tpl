#!/bin/bash -xe

{{$keystone := .Values.openstack.service_map.keystone}}
{{$admin_password := .Values.openstack.admin_password}}

/opt/kubernetes/bin/helm get openstack-nova \
    || /opt/kubernetes/bin/helm install /opt/openstack-helm/nova \
        --name openstack-nova

/opt/nova/bin/nova-manage api_db sync

/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell0 || /opt/nova/bin/nova-manage cell_v2 map_cell0
/opt/nova/bin/nova-manage cell_v2 list_cells | grep cell1 || /opt/nova/bin/nova-manage cell_v2 create_cell --name=cell1 --verbose
/opt/nova/bin/nova-manage db sync


source /etc/openstack/adminrc
openstack flavor show 1v-512M-4G \
  || openstack flavor create --vcpus 1 --ram 512 --disk 4 --public 1v-512M-4G
