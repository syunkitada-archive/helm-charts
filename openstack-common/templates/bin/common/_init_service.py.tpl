# coding: utf-8

import time
import hashlib
import os
import service


def main():
    process = None
    service.init()

    watch_files = []
    for watch_file in service.WATCH_FILES:
        watch_files.append({
            'file': watch_file,
            'current_hash': md5(watch_file),
        })

    while True:
        is_reload = False
        for watch_file in watch_files:
            tmp_hash = md5(watch_file['file'])
            if tmp_hash != watch_file['current_hash']:
                is_reload = True
                watch_file['current_hash'] = tmp_hash

        if process is None:
            print('service start.')
            process = service.start()

        if not check_pid(process):
            print('service pid is not found.')
            print('service start.')
            process = service.start()

        elif not service.check(process):
            print('service check is failed.')
            if check_pid(process):
                print('service stop. {0}'.format(process.pid))
                service.stop(process)

            print('service start.')
            process = service.start()

        if is_reload:
            print('file changed and service start.')
            p = service.reload(process)
            if p is not None:
                process = p

        time.sleep(service.WATCH_INTERVAL)


def md5(filename):
    hash_md5 = hashlib.md5()
    with open(filename, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


import re
RE_STATE = re.compile(".*State:[ \t]+([A-Z]) .*")


def check_pid(p):
    try:
        os.kill(p.pid, 0)
        with open('/proc/{0}/status'.format(p.pid), 'r') as f:
            status = f.readlines()
        m = RE_STATE.search(status[1])
        if m is None:
            return False

        status = m.group(1)
        if status == 'Z':
            # If the parent process is ignoring output,
            # the Popen call cannot destroy
            # the process as it has data sitting in a pipe.
            # https://www.reddit.com/r/learnpython/comments/3lzv4r/subprocess_becomes_zombie_why/
            p.poll()
            return False

    except OSError:
        return False

    return True


if __name__ == '__main__':
    main()
