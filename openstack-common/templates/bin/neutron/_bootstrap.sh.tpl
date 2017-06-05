#!/bin/sh -xe

echo 'Starting bootstrap'

mkdir -p /etc/neutron/plugins/ml2

rm -rf /etc/neutron/neutron.conf
ln -s /mnt/etc/neutron/neutron.conf /etc/neutron/neutron.conf

rm -rf /etc/neutron/plugins/ml2/ml2_conf.ini
ln -s /mnt/etc/neutron/ml2_conf.ini /etc/neutron/plugins/ml2/ml2_conf.ini

rm -rf /etc/neutron/plugins/ml2/linuxbridge_agent.ini
ln -s /mnt/etc/neutron/linuxbridge_agent.ini /etc/neutron/plugins/ml2/linuxbridge_agent.ini

rm -rf /etc/neutron/dhcp_agent.ini
ln -s /mnt/etc/neutron/dhcp_agent.ini /etc/neutron/dhcp_agent.ini

rm -rf /etc/neutron/metadata_agent.ini
ln -s /mnt/etc/neutron/metadata_agent.ini /etc/neutron/metadata_agent.ini

echo 'Success bootstrap'
