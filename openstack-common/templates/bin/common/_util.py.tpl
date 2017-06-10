# coding: utf-8

import os, stat
import subprocess
from logging import getLogger, StreamHandler, DEBUG


def getLog(name):
    LOG_LEVEL = os.environ.get('LOG_LEVEL', DEBUG)
    logger = getLogger(name)
    handler = StreamHandler()
    handler.setLevel(DEBUG)
    logger.setLevel(DEBUG)
    logger.addHandler(handler)
    return logger


LOG = getLog(__name__)


def execute(cmd, is_chmod=False):
    msg = "bash: {0}".format(cmd)
    if is_chmod:
        os.chmod(cmd[0], stat.S_IXUSR)
    LOG.info(msg)

    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = ''
    for line in iter(p.stdout.readline, b''):
        LOG.info(line)
        stdout += line.decode('utf-8')

    return_code = p.wait()
    stderr = p.stderr.read().decode('utf-8')

    p.stdout.close()
    p.stderr.close()

    msg = "bash: {0}, return_code: {1}\n  stderr: {2}\n".format(cmd, return_code, stderr)
    LOG.info(msg)

    return {
        'return_code': return_code,
        'stdout': stdout,
        'stderr': stderr,
    }


def execute_bootstrap():
    for root, dirs, files in os.walk('/mnt/bin/'):
        for file in files:
            if file == 'bootstrap.sh':
                bootstrap_file = os.path.join(root, file)
                result = execute([bootstrap_file], is_chmod=True)
                if result['return_code'] != 0:
                    raise Exception('Failed bootstrap')
                return
