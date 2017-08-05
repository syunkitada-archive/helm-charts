#!/bin/bash -xe

source /mnt/openstack/etc/adminrc

helm get values openstack > /tmp/values.yaml
helm get openstack-glance \
    || helm install charts/glance \
        --name openstack-glance -f /tmp/values.yaml

kubectl get cm glance-etc -o jsonpath='{.data.glance-api\.conf}' > /etc/glance/glance-api.conf

/opt/glance/bin/glance-manage db_sync


cd /tmp/
image_list=`openstack image list`

echo $image_list | grep cirros \
    || ( \
curl -O http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img; \
openstack image create "cirros" \
  --file cirros-0.3.5-x86_64-disk.img \
  --disk-format qcow2 --container-format bare \
  --public )
