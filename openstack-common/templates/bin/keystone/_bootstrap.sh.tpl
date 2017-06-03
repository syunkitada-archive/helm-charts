#!/bin/sh -xe

echo 'Starting bootstrap'

mkdir -p /etc/keystone

rm -rf /etc/keystone/keystone.conf
ln -s /mnt/etc/keystone/keystone.conf /etc/keystone/keystone.conf

# rm -rf /etc/keystone/fernet-keys/
# ln -s /mnt/fernet-keys /etc/keystone/fernet-keys
mkdir -p /etc/keystone/fernet-keys
/opt/keystone/bin/keystone-manage fernet_setup --keystone-user root --keystone-group root
/opt/keystone/bin/keystone-manage credential_setup --keystone-user root --keystone-group root

echo 'Success bootstrap'
