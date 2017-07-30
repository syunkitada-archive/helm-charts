#!/bin/bash -xe

echo 'Starting nova'

COMMAND="${@:-start}"


function bootstrap() {
    export PATH=$PATH:/opt/nova/bin
    source /mnt/openstack/etc/resolvrc
    mkdir -p /var/lib/nova/instances
    cp /mnt/nova/etc/nova.conf /etc/nova/
}


function start_api() {
    bootstrap
    /opt/nova/bin/nova-api --config-file=/etc/nova/nova.conf
}


function start_scheduler() {
    bootstrap
    /opt/nova/bin/nova-scheduler --config-file /etc/nova/nova.conf
}


function start_conductor() {
    bootstrap
    /opt/nova/bin/nova-conductor --config-file /etc/nova/nova.conf
}


function liveness_api() {
    echo "liveness"
}


function readiness_api() {
    echo "readiness"
}


function liveness() {
    echo "liveness"
}


function readiness() {
    echo "readiness"
}


$COMMAND
