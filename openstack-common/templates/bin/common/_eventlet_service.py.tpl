# coding: utf-8

import os
import subprocess

WATCH_FILES = []
WATCH_INTERVAL = 10
START_CMD = os.environ['START_CMD']
cmd = '{0}'.format(START_CMD)


def init():
    for root, dirs, files in os.walk('/mnt/bin/'):
        for file in files:
            if file == 'bootstrap.sh':
                bootstrap_file = os.path.join(root, file)
                p = subprocess.Popen(['/bin/sh', bootstrap_file], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
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
