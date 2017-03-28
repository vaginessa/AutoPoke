#!/usr/bin/python

import sys
import socket
from libnmap.parser import NmapParser


if len(sys.argv) != 2:
    print 'Usage: ' + sys.argv[0] + ' nmap-report.xml'
    sys.exit(0)

nmap_report = NmapParser.parse_fromfile(sys.argv[1])

portlist = []

for scanned_host in nmap_report.hosts:

    for open_service in scanned_host.services:
        if open_service.service == 'http' or open_service.service == 'http-alt' or open_service.service == 'https' or open_service.service == 'https-alt':
            portlist.append(str(open_service.port)) # add port to list

# make portlist unique
portlist = list(set(portlist))

# try to connect to the http ports on every subdomain, report the ones that were succesful
for line in sys.stdin:

    hostports = []

    for port in portlist:
        s = socket.socket()
        s.settimeout(10) # timeout of 10 sec
        try:
            address = socket.gethostbyname(line.rstrip('\n'))
            s.connect((address, int(port)))
            hostports.append(port)
        except Exception as e:
            # this host is probably not serving on this port!
            pass
        finally:
            s.close()

    hostportstring = ",".join(hostports)
    print line.rstrip('\n') + '|' + hostportstring
