# coding: utf-8

import subprocess
import time
import hashlib
import os

WATCH_FILES  = os.environ['WATCH_FILES']
WATCH_INTERVAL = int(os.environ['WATCH_INTERVAL'])


def main():
    process = None

    watch_files = []
    for watch_file in WATCH_FILES.split(','):
        watch_files.append({
            'file': watch_file,
            'current_hash': md5(watch_file),
        })

    for watch_file in watch_files:
        p = subprocess.Popen(['/bin/bash', watch_file['file']], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        stdout_data, stderr_data = p.communicate()
        print(stdout_data)

    while True:
        for watch_file in watch_files:
            tmp_hash = md5(watch_file['file'])
            if tmp_hash != watch_file['current_hash']:
                watch_file['current_hash'] = tmp_hash
                p = subprocess.Popen(['/bin/bash', watch_file['file']], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                stdout_data, stderr_data = p.communicate()
                print(stdout_data)

        time.sleep(WATCH_INTERVAL)


def md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


if __name__ == '__main__':
    main()
