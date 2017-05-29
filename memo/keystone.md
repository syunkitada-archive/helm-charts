sudo docker run -i -t ubuntu:16.10

mysql -uroot -prootpass -e 'create database keystone'
mysql -uroot -prootpass -e 'create database glance'
mysql -uroot -prootpass -e 'create database nova'
mysql -uroot -prootpass -e 'create database neutron'
mysql -uroot -prootpass -e 'create database horizon'

/opt/keystone/bin/keystone manage db_sync
/opt/keystone/bin/keystone-manage fernet_setup --keystone-user root --keystone-group root
/opt/keystone/bin/keystone-manage credential_setup --keystone-user root --keystone-group root


/opt/keystone/bin/keystone-manage bootstrap --bootstrap-password adminpass \
  --bootstrap-admin-url http://localhost:35357/v3/ \
  --bootstrap-internal-url http://localhost:5000/v3/ \
  --bootstrap-public-url http://localhost:5000/v3/ \
  --bootstrap-region-id RegionOne



/opt/keystone/bin/uwsgi --http :5000 --wsgi-file /opt/keystone/bin/keystone-wsgi-public --processes 4 --threads 1 > /dev/null &
/opt/keystone/bin/uwsgi --http :35357 --wsgi-file /opt/keystone/bin/keystone-wsgi-public --processes 4 --threads 1 > /dev/null &


openstack service create --name glance --description "OpenStack Image" image
openstack endpoint create --region RegionOne image public http://localhost:9292
openstack endpoint create --region RegionOne image internal http://localhost:9292
openstack endpoint create --region RegionOne image admin http://localhost:9292

openstack service create --name neutron --description "OpenStack Networking" network
openstack endpoint create --region RegionOne network public http://localhost:9696
openstack endpoint create --region RegionOne network internal http://localhost:9696
openstack endpoint create --region RegionOne network admin http://localhost:9696

export OS_USERNAME=admin
export OS_PASSWORD=adminpass
export OS_PROJECT_NAME=admin
export OS_USER_DOMAIN_NAME=Default
export OS_PROJECT_DOMAIN_NAME=Default
export OS_AUTH_URL=http://localhost:35357/v3
export OS_IDENTITY_API_VERSION=3


openstack user create --domain default --password openstackpass openstack
openstack project create service
openstack role add --project service --user openstack admin
