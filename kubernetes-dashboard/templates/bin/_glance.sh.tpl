#!/bin/bash -xe

echo 'Starting glance'

COMMAND="${@:-start}"


function bootstrap() {
    source /mnt/openstack/etc/resolvrc
    cp /mnt/glance/etc/glance-api.conf /etc/glance/
    cp /mnt/glance/etc/glance-registry.conf /etc/glance/
}


function start_api() {
    bootstrap
    /opt/glance/bin/glance-api --config-file /etc/glance/glance-api.conf
}


function start_registry() {
    bootstrap
    /opt/glance/bin/glance-registry --config-file /etc/glance/glance-registry.conf
}


function liveness_api() {
    echo "liveness"
}


function readiness_api() {
    echo "readiness"
}


function liveness_registry() {
    echo "liveness"
}


function readiness_registry() {
    echo "readiness"
}


$COMMAND
