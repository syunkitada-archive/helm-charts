#!/bin/bash -xe

echo 'Starting neutron'

COMMAND="${@:-start}"


function bootstrap() {
    source /mnt/openstack/etc/resolvrc
    cp /mnt/neutron/etc/neutron.conf /etc/neutron/
    cp /mnt/neutron/etc/ml2_conf.ini /etc/neutron/
}


function start() {
    bootstrap
    /opt/neutron/bin/neutron-server \
        --config-file /etc/neutron/neutron.conf \
        --config-file /etc/neutron/ml2_conf.ini
}


function liveness() {
    echo "liveness"
}


function readiness() {
    echo "readiness"
}


$COMMAND
