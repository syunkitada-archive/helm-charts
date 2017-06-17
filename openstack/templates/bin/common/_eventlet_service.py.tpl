# coding: utf-8

import os
import subprocess
import util

LOG = util.getLog(__name__)
WATCH_FILES = os.environ.get('WATCH_FILES', '').split(',')
WATCH_INTERVAL = int(os.environ.get('WATCH_INTERVAL', 10))
START_CMD = os.environ['START_CMD']
cmd = '{0}'.format(START_CMD)


def init():
    util.execute_bootstrap()


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
