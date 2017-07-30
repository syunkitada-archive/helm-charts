#!/bin/bash -xe

echo 'Starting nova'

COMMAND="${@:-start}"


function bootstrap() {
    export PATH=$PATH:/opt/nova/bin
    source /mnt/openstack/etc/resolvrc
    mkdir -p /var/lib/nova/instances
    cp /mnt/nova/etc/nova.conf /etc/nova/
}


function bootstrap_compute() {
    cp /etc/yum.repos.d/openstack.repo /host/etc/yum.repos.d/openstack.repo
    chroot /host yum install -y epel-release
    chroot /host yum install -y vde2-2.3.2 qemu-2.9.0
    chroot /host yum install libvirt
    cp /mnt/nova/etc/qemu.conf /host/etc/libvirt/
    chroot /host useradd qemu || echo "Already exists qemu user"
    chroot /host systemctl restart libvirtd
    yum install -y libvirt-python sysfsutils dbus genisoimage
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


function start_compute() {
    bootstrap
    bootstrap_compute
    /opt/nova/bin/nova-compute --config-file /etc/nova/nova.conf
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
