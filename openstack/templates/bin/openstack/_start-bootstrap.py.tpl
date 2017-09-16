#!/usr/bin/env python
# coding: utf-8

import subprocess
import time
import hashlib
import os
import util

LOG = util.getLog(__name__)
WATCH_DIR  = os.environ.get('WATCH_DIR', '/mnt/openstack/bin')
WATCH_INTERVAL = int(os.environ.get('WATCH_INTERVAL', 10))
VALUES_FILE = '/mnt/openstack/etc/values'


def main():
    LOG.info('start controller')
    process = None
    bootstrap_map = {}

    while True:
        bootstrap_files = []
        for root, dirs, files in os.walk(WATCH_DIR):
            for file in files:
                if file.find('bootstrap-') == 0:
                    bootstrap_file = os.path.join(root, file)
                    bootstrap_files.append(bootstrap_file)

        bootstrap_files.sort()

        for bootstrap_file in bootstrap_files:
            bootstrap = bootstrap_map.get(bootstrap_file, {
                'current_hash': '',
            })
            tmp_hash = sha256(bootstrap_file)
            if tmp_hash != bootstrap['current_hash']:
                LOG.info('{0} is changed'.format(bootstrap_file))
                cmd = [bootstrap_file]
                result = util.execute(cmd)
                if result['return_code'] != 0:
                    raise Exception('Failed cmd: {0}'.format(cmd))

                bootstrap['current_hash'] = tmp_hash
                bootstrap_map[bootstrap_file] = bootstrap

        tmp_hash = sha256(VALUES_FILE)
        tmp_file = bootstrap_map.get(VALUES_FILE, {
            'current_hash': '',
        })

        LOG.info('sleep {0}'.format(WATCH_INTERVAL))
        time.sleep(WATCH_INTERVAL)


def sha256(filename):
    hash_sha256 = hashlib.sha256()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_sha256.update(chunk)
    return hash_sha256.hexdigest()


if __name__ == '__main__':
    main()
