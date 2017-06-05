# coding: utf-8

import os
import subprocess

WATCH_FILES = []
WATCH_INTERVAL = 10
SERVER_PORT = os.environ['SERVER_PORT']
UWSGI_SCRIPT_NAME = os.environ['UWSGI_SCRIPT_NAME']
UWSGI_FILE = os.environ['UWSGI_FILE']
UWSGI_PORT = os.environ['UWSGI_PORT']
UWSGI_PROCESSES = os.environ['UWSGI_PROCESSES']
UWSGI_THREADS = os.environ['UWSGI_THREADS']
cmd = '/opt/keystone/bin/uwsgi --socket 127.0.0.1:{0} --master --wsgi-file {1} --processes {2} --threads {3}'.format(
    UWSGI_PORT, UWSGI_FILE, UWSGI_PROCESSES, UWSGI_THREADS)


def init():
    for root, dirs, files in os.walk('/mnt/bin/'):
        for file in files:
            if file == 'bootstrap.sh':
                bootstrap_file = os.path.join(root, file)
                p = subprocess.Popen(['/bin/sh', bootstrap_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout_data, stderr_data = p.communicate()
                print(stdout_data)

    create_nginx_conf()
    p = subprocess.Popen(['service', 'nginx', 'start'], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout_data, stderr_data = p.communicate()
    print(stdout_data)


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


def create_nginx_conf():
    with open('/etc/nginx/sites-available/default', 'w') as f:
        f.write("""
server {{"{{"}}
    listen {server_port};
    location / {{"{{"}}
      uwsgi_pass 127.0.0.1:{uwsgi_port};
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
   {{"}}"}}
{{"}}"}}""".format(uwsgi_script_name=UWSGI_SCRIPT_NAME, server_port=SERVER_PORT, uwsgi_port=UWSGI_PORT))
