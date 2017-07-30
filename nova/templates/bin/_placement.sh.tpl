#!/bin/bash -xe

echo 'Starting nova'

COMMAND="${@:-start}"


function bootstrap() {
    source /mnt/openstack/etc/resolvrc
    cp /mnt/nova/etc/nova.conf /etc/nova/
}


function start_placement() {
    bootstrap
    /opt/openstack-tools/bin/uwsgi \
        --socket 127.0.0.1:8000 --master \
        --home /opt/nova \
        --wsgi-file /opt/nova/bin/nova-placement-api \
        --processes 2 --threads 1
}


function start_nginx() {
    cp /mnt/placement/etc/nginx-placement.conf /etc/nginx/conf.d/
    nginx -g "daemon off;"
}


function liveness() {
    echo "liveness"
}


function readiness() {
    echo "readiness"
}


$COMMAND
