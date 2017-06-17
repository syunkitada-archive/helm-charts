#!/bin/sh -xe

echo 'Starting bootstrap'

ln -s /mnt/etc/horizon/local_settings.py /opt/horizon/share/horizon/openstack_dashboard/local/local_settings.py
cd /opt/horizon/share/horizon
cp openstack_dashboard/wsgi/django.wsgi openstack_dashboard/wsgi/wsgi
/opt/horizon/bin/python manage.py collectstatic --noinput
/opt/horizon/bin/python manage.py compress --force

echo 'Success bootstrap'
