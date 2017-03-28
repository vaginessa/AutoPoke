#!/usr/bin/python

import socket
import fileinput

for line in fileinput.input():
    try:
        print socket.gethostbyname(line.rstrip('\n'))
    except socket.gaierror:
        pass

