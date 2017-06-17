#!/bin/sh -xe

echo 'Starting bootstrap'

mkdir -p /etc/nova
mkdir -p /var/lib/nova/tmp

rm -rf /etc/nova/nova.conf
ln -s /mnt/etc/nova/nova.conf /etc/nova/nova.conf

echo 'Success bootstrap'
