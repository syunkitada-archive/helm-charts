#!/bin/sh -xe

echo 'Starting bootstrap'

mkdir -p /etc/glance

rm -rf /etc/glance/glance-api.conf
rm -rf /etc/glance/glance-registry.conf
ln -s /mnt/etc/glance/glance-api.conf /etc/glance/glance-api.conf
ln -s /mnt/etc/glance/glance-registry.conf /etc/glance/glance-registry.conf

mkdir -p /var/lib/glance/images/

echo 'Success bootstrap'
