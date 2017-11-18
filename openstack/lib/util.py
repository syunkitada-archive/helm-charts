# coding: utf-8

import hashlib
import os
import stat
import subprocess
import re
from oslo_config import cfg
from oslo_log import log

CONF = cfg.CONF
LOG = log.getLogger(__name__)

RE_HELM_LIST = re.compile('^([a-zA-Z0-9\-]+)[ \t]+([\d]+)[ \t]+.*[ \t]+([A-Z]+)[ \t]+([a-zA-Z0-9\-]+)-([0-9\.]+)[ \t]+.*')  # noqa


def execute(cmd, is_chmod=False, enable_exception=True):
    msg = "bash: {0}".format(cmd)
    if is_chmod:
        os.chmod(cmd[0], stat.S_IXUSR)
    LOG.info(msg)

    p = subprocess.Popen(cmd.split(' '), stdout=subprocess.PIPE, stderr=subprocess.PIPE)
    stdout = ''
    while True:
        line = p.stdout.readline()
        LOG.debug(line[:-1])
        stdout += line
        if not line and p.poll() is not None:
            break

    return_code = p.wait()
    stderr = p.stderr.read().decode('utf-8')

    p.stdout.close()
    p.stderr.close()

    msg = "bash: {0}, return_code: {1}\n  stderr: {2}\n".format(cmd, return_code, stderr)
    LOG.info(msg)
    if enable_exception:
        if return_code != 0:
            raise Exception('Failed cmd: {0}'.format(cmd))

    return {
        'return_code': return_code,
        'stdout': stdout,
        'stderr': stderr,
    }


def sha256(filename):
    hash_sha256 = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()


class Helm():
    def __init__(self):
        os.environ['TILLER_NAMESPACE'] = CONF.k8s.tiller_namespace
        self.k8s_namespace = CONF.k8s.namespace
        self.chart_repo_prefix = CONF.k8s.chart_repo_prefix
        self.values_file = CONF.k8s.values_file
        execute('helm init -c')
        execute('helm repo add {0} {1}'.format(CONF.k8s.chart_repo_name, CONF.k8s.chart_repo))

    def install(self, name, chart):
        execute('helm install --namespace {0} --name {1} {2}/{3} -f {4}'.format(
                        self.k8s_namespace, name,  self.chart_repo_prefix, chart,
                        self.values_file
                     ))

    def delete(self, name):
        execute('helm delete --purge {0}'.format(name))

    def upgrade(self, name, chart, option=''):
        execute("helm upgrade {0} {1}/{2} {3}".format(
                        name, self.chart_repo_prefix, chart, option))

    def get_resource_map(self):
        resource_map = {}
        result = execute('helm repo update')
        result = execute('helm list')
        for line in result['stdout'].split('\n'):
            m = RE_HELM_LIST.match(line)
            if m is None:
                continue

            resource_name = m.group(1)
            revision = m.group(2)
            status = m.group(3)
            chart = m.group(4)
            version = m.group(5)

            resource_map[resource_name] = {
                'revision': revision,
                'status': status,
                'chart': chart,
                'version': version,
            }

        return resource_map
