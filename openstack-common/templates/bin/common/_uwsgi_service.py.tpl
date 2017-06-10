# coding: utf-8

import util
import os
import subprocess

LOG = util.getLog(__name__)
WATCH_FILES = os.environ.get('WATCH_FILES', '').split(',')
WATCH_INTERVAL = os.environ.get('WATCH_INTERVAL', 10)
SERVER_PORT = os.environ['SERVER_PORT']
UWSGI_PATH = os.environ.get('UWSGI_PATH')
UWSGI_FILE = os.environ.get('UWSGI_FILE')
UWSGI_PORT = os.environ.get('UWSGI_PORT', 3301)
UWSGI_PROCESSES = os.environ.get('UWSGI_PROCESSES', 1)
UWSGI_THREADS = os.environ.get('UWSGI_THREADS', 1)
cmd = '{path} --socket 127.0.0.1:{port} --master --wsgi-file {file} --processes {processes} --threads {threads}'.format(
    path=UWSGI_PATH, port=UWSGI_PORT, file=UWSGI_FILE,
    processes=UWSGI_PROCESSES, threads=UWSGI_THREADS
)

IS_DJANGO = bool(os.environ.get('IS_DJANGO', True))
UWSGI_CHDIR = os.environ.get('UWSGI_CHDIR', '/opt/horizon/share/horizon')
UWSGI_MODULE = os.environ.get('UWSGI_MODULE', 'openstack_dashboard/wsgi/wsgi:application')
DJANGO_SETTINGS_MODULE = os.environ.get('DJANGO_SETTINGS_MODULE', 'openstack_dashboard.settings')
UWSGI_HOME = os.environ.get('UWSGI_HOME', '/opt/horizon')
STATIC_PATH = os.environ.get('STATIC_PATH')
django_cmd = '/opt/keystone/bin/uwsgi --chdir={chdir} --module={module} --env DJANGO_SETTINGS_MODULE={settings_module} --master --socket=127.0.0.1:{port} --processes={processes} --home={home}'.format(
    chdir=UWSGI_CHDIR, module=UWSGI_MODULE, settings_module=DJANGO_SETTINGS_MODULE,
    home=UWSGI_HOME, processes=UWSGI_PROCESSES, threads=UWSGI_THREADS, port=UWSGI_PORT
)


def init():
    util.execute_bootstrap()

    create_nginx_conf()
    result = util.execute(['service', 'nginx', 'start'])
    if result['return_code'] != 0:
        raise Exception('Failed start nginx')


def start():
    if IS_DJANGO:
        p = subprocess.Popen(django_cmd.split(' '))
    else:
        p = subprocess.Popen(cmd.split(' '))
    LOG.info('started service {0}'.format(p.pid))
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
    location_str = ""
    if STATIC_PATH is not None:
        location_str = """
    location /static {{"{{"}}
      alias {0};
    {{"}}"}}
""".format(STATIC_PATH)

    with open('/etc/nginx/sites-available/default', 'w') as f:
        f.write("""
server {{"{{"}}
    listen {server_port};
    location / {{"{{"}}
      uwsgi_pass 127.0.0.1:{uwsgi_port};
      uwsgi_param SCRIPT_NAME '';
      include uwsgi_params;
   {{"}}"}}
   {location_str}
{{"}}"}}""".format(server_port=SERVER_PORT, uwsgi_port=UWSGI_PORT, location_str=location_str))
