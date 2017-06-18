#!/bin/sh -xe

/opt/neutron/bin/neutron-db-manage --config-file /etc/neutron/neutron.conf --config-file /etc/neutron/ml2_conf.ini upgrade head
