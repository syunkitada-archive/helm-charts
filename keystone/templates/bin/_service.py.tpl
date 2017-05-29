# coding: utf-8

import os
import subprocess

watch_files = []
watch_interval = 10
UWSGI_FILE = os.environ['UWSGI_FILE']
UWSGI_PORT = os.environ['UWSGI_PORT']
UWSGI_PROCESSES = os.environ['UWSGI_PROCESSES']
UWSGI_THREADS = os.environ['UWSGI_THREADS']
cmd = '/opt/keystone/bin/uwsgi --socket 127.0.0.1:{0} --wsgi-file {1} --processes {2} --threads {3}'.format(
    UWSGI_PORT, UWSGI_FILE, UWSGI_PROCESSES, UWSGI_THREADS)


def init():
    conf_file = '/etc/keystone/keystone.conf'
    if os.path.exists(conf_file):
        os.remove(conf_file)
    os.symlink('/mnt/keystone-etc/keystone.conf', conf_file)


def start():
    p = subprocess.Popen(cmd.split(' '))
    print('started service {0}'.format(p.pid))
    return p


def stop(process):
    process.kill()
    process.poll()


def reload(process):
    stop(process)
    return start(process)


def check(process):
    return True
