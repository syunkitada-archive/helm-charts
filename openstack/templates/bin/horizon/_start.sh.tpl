#!/bin/sh -xe

echo 'Starting bootstrap'

cp /etc/horizon/local_settings.py /opt/horizon/share/horizon/openstack_dashboard/local/local_settings.py
cd /opt/horizon/share/horizon
cp openstack_dashboard/wsgi/django.wsgi openstack_dashboard/wsgi/wsgi
/opt/horizon/bin/python manage.py collectstatic --noinput
/opt/horizon/bin/python manage.py compress --force

echo 'Success bootstrap'

echo 'Start service'

/opt/openstack-tools/bin/uwsgi --socket 127.0.0.1:8080 --master \
  --home /opt/horizon --wsgi-file /opt/horizon/share/horizon/openstack_dashboard/wsgi/django.wsgi \
  --chdir /opt/horizon/share/horizon --env DJANGO_SETTINGS_MODULE=openstack_dashboard.settings \
  --processes 2 --threads 1
