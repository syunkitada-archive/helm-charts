#!/bin/sh -xe

echo 'Starting bootstrap'

mkdir -p /var/lib/nova/tmp
mkdir -p /var/lib/nova/instances
echo 'Success bootstrap'

# for module in `ls /usr/lib/python3/dist-packages/ | grep libvirt`
# do
#     ln -s /usr/lib/python3/dist-packages/$module /opt/nova/lib/python3.5/site-packages/
# done

echo 'Start nova-compute'
/opt/nova/bin/nova-compute --config-file /etc/nova/nova.conf
