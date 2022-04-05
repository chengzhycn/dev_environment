#!/bin/env python3

import requests
import shutil
import logging
from io import StringIO

HOST_FILE_PATH = "/etc/hosts"
TMP_HOST_PATH = "/tmp/hosts"
REMOTE_HOSTS_URL = "https://gitee.com/ineo6/hosts/raw/master/hosts"

CUSTOM_HOSTS_START_MARK = "### Custom hosts start\n"
CUSTOM_HOST_END_MARK = "### Custom hosts end\n"

LOGGING_FILE = "/var/log/customs/hosts_sync.log"
logging.basicConfig(filename=LOGGING_FILE, level=logging.DEBUG,
        format='%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s')


def request_latest_hosts(buf: StringIO) -> bool:
    response = requests.get(REMOTE_HOSTS_URL)
    if response.status_code == 200:
        buf.write(CUSTOM_HOSTS_START_MARK)
        # TODO: check the data's validity.
        buf.write(response.text + "\n")
        buf.write(CUSTOM_HOST_END_MARK)

        return True

    logging.error("failed to requests latest host content, status code is %d" % response.status_code)
    return False


def read_host_file(buf: StringIO) -> bool:
    custom_line = False

    try:
        with open(HOST_FILE_PATH, "r") as f:
            for line in f:
                if line.startswith(CUSTOM_HOSTS_START_MARK):
                    custom_line = True
                elif line.startswith(CUSTOM_HOST_END_MARK):
                    custom_line = False

                if not custom_line:
                    buf.write(line)

        return True

    except Exception as e:
        logging.error("failed to read current host file's data: %s" % e)
        return False



def main():
    buffer = StringIO()

    if read_host_file(buffer) and request_latest_hosts(buffer):
        try:
            with open(TMP_HOST_PATH, "w") as f:
                f.write(buffer.getvalue())

            # need sudo privilege.
            shutil.move(TMP_HOST_PATH, HOST_FILE_PATH)
            logging.debug("update host file successfully.")
        except Exception as e:
            logging.error("failed to write tmp host file to the /etc/hosts: %s" % e)
            shutil.rmtree(TMP_HOST_PATH)

    buffer.close()
    return


if __name__ == '__main__':
    main()
