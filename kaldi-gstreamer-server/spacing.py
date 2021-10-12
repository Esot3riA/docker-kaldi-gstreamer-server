#!/usr/bin/env python3.7

import sys
import json
import re
from pykospacing import Spacing

if __name__ == "__main__":
    #    logging.basicConfig(level=logging.DEBUG, format="%(levelname)8s %(asctime)s %(message)s ")

    lines = []
    spacing = Spacing()

    #    while True:
    #        sys.stdin.reconfigure(encoding='utf-8')
    l = sys.stdin.readline()
    #        if not l: break

    new_sent = spacing(l)
    new_sent = re.sub('(.*)', '\\1.', new_sent)
    print (new_sent)
    sys.stdout.flush()
    lines = []

    if len(lines) > 0:
        sent = "".join(lines)
        new_sent = spacing(sent)
        new_sent = re.sub('(.*)', '\\1.', new_sent)
        print (new_sent)
        lines = []