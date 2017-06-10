#!/usr/bin/env python
# coding: utf-8

import subprocess
import time
import hashlib
import os
import util

LOG = util.getLog(__name__)
WATCH_FILES  = os.environ['WATCH_FILES']
WATCH_INTERVAL = int(os.environ['WATCH_INTERVAL'])


def main():
    LOG.info('start controller')
    process = None

    watch_files = []
    for watch_file in WATCH_FILES.split(','):
        watch_files.append({
            'file': watch_file,
            'current_hash': '',
        })

    while True:
        for watch_file in watch_files:
            tmp_hash = md5(watch_file['file'])
            if tmp_hash != watch_file['current_hash']:
                watch_file['current_hash'] = tmp_hash
                cmd = [watch_file['file']]
                result = util.execute(cmd, is_chmod=True)
                if result['return_code'] != 0:
                    raise Exception('Failed cmd: {0}'.format(cmd))

        time.sleep(WATCH_INTERVAL)


def md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


if __name__ == '__main__':
    main()
