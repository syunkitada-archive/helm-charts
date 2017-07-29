#!/bin/bash -xe

echo 'Starting keystone'
source /mnt/openstack/etc/resolvrc

COMMAND="${@:-start}"


function prepare_conf() {
    cp /mnt/keystone/etc/keystone.conf /etc/keystone/
}


function start_public() {
    prepare_conf
    /opt/openstack-tools/bin/uwsgi \
        --socket 127.0.0.1:8000 --master \
        --home /opt/keystone \
        --wsgi-file /opt/keystone/bin/keystone-wsgi-admin \
        --processes 2 --threads 1
}


function start_admin() {
    prepare_conf
    /opt/openstack-tools/bin/uwsgi \
        --socket 127.0.0.1:8080 --master \
        --home /opt/keystone \
        --wsgi-file /opt/keystone/bin/keystone-wsgi-admin \
        --processes 2 --threads 1
}


function start_nginx() {
    cp /mnt/keystone/etc/nginx-keystone.conf /etc/nginx/conf.d/
    nginx -g "daemon off;"
}


function liveness() {
    echo "liveness"
}


$COMMAND
