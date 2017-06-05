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
            'current_hash': '',
        })

    while True:
        for watch_file in watch_files:
            tmp_hash = md5(watch_file['file'])
            if tmp_hash != watch_file['current_hash']:
                watch_file['current_hash'] = tmp_hash
                p = subprocess.Popen(['/bin/bash', '-xe', watch_file['file']], stdout=subprocess.PIPE, stderr=subprocess.PIPE)
                return_code = p.wait()
                print("return_code: {0}\nstdout: {1}\nstderr:{2}\n".format(
                    return_code, p.stdout, p.stderr
                ))
                if return_code != 0:
                    exit(return_code)

        time.sleep(WATCH_INTERVAL)


def md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


if __name__ == '__main__':
    main()
