#!/bin/bash -xe

echo 'Starting horizon'

COMMAND="${@:-start}"


function bootstrap() {
    source /mnt/openstack/etc/resolvrc
    cp /mnt/horizon/etc/local_settings.py /etc/horizon/
}


function start() {
    bootstrap
    /opt/openstack-tools/bin/uwsgi --socket 127.0.0.1:8001 --master \
      --home /opt/horizon --wsgi-file /opt/horizon/share/horizon/openstack_dashboard/wsgi/django.wsgi \
      --chdir /opt/horizon/share/horizon --env DJANGO_SETTINGS_MODULE=openstack_dashboard.settings \
      --processes 2 --threads 1
}


function start_nginx() {
    cp /mnt/horizon/etc/nginx-horizon.conf /etc/nginx/conf.d/
    nginx -g "daemon off;"
}


function liveness() {
    echo "liveness"
}


function readiness() {
    echo "readiness"
}


$COMMAND
