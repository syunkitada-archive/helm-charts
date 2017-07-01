# coding: utf-8

import os, stat
import subprocess
from logging import getLogger, StreamHandler, DEBUG, Formatter


def getLog(name):
    LOG_LEVEL = os.environ.get('LOG_LEVEL', DEBUG)
    logger = getLogger(name)
    formatter = Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
    handler = StreamHandler()
    handler.setLevel(DEBUG)
    handler.setFormatter(formatter)
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
