#!/bin/bash -xe

helm get openstack-glance \
    || helm install /opt/openstack-helm/glance \
        --name openstack-glance

/opt/glance/bin/glance-manage db_sync

source /etc/openstack/adminrc

cd /tmp/
image_list=`openstack image list`

echo $image_list | grep cirros \
    || ( \
curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img; \
openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public )
