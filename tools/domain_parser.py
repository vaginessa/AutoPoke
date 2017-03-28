#!/usr/bin/python

import sys
import re

domainregex = r'(?:[a-zA-Z0-9](?:[a-zA-Z0-9\-]{,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,6}'

domainlist = []

for line in sys.stdin:
    domainlist.extend(re.findall(domainregex, line))

for i in domainlist:
    if len(sys.argv) > 1:
        if sys.argv[1] in i:
            print i
    else:
        print i

