#!/usr/bin/python

import fileinput
import re

ipregex = r'[0-9]+(?:\.[0-9]+){3}'

iplist = []

for line in fileinput.input():

    if 'Subnets found ' in line: # break before reading the suggested ranges in fierce output
        break

    iplist.extend(re.findall(ipregex, line))

for i in iplist:
    print i

