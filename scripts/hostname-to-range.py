#!/usr/bin/python3

#
# input: hostnames
#
#
# saved: list of (hostname, ip)
#
#
# output: ip ranges
#


import ipaddress
import pickle
import socket
import sys
from termcolor import colored

# check the arguments
if len(sys.argv) is not 2:
    print('Usage: ' + sys.argv[0] + ' filename')
    sys.exit(-1)


ipToHostname = [] # (hostname, ip)


# for each hostname, get the ip
for hostname in sys.stdin:
    try:
        ipToHostname.append((hostname.strip(),socket.gethostbyname(hostname.strip())))
    except Exception as e:
        print(colored(str(hostname) + ': ' + str(e),"red"), file=sys.stderr)


# save the hostname-ip list for later use
with open(sys.argv[1], 'wb+') as f:
    pickle.dump(ipToHostname, f)


ipRanges = [] # (range, [ips])


# group hosts into networks by /24
for host in ipToHostname:
    assigned = False
    for ipRange in ipRanges:
        ipadr = ipaddress.IPv4Address(host[1])
        if ipadr in ipRange[0]:
            ipRange[1].append(ipadr)
            assigned = True
            break
    if not assigned:
        ipRanges.append((ipaddress.ip_network(host[1] + '/24', strict=False), [ipaddress.IPv4Address(host[1])]))


# calculate the cidr formats of the ranges between the lowest and highest ip
for ipRange in ipRanges:
    startip = min(ipRange[1])
    endip = max(ipRange[1])
    cidrList = [ipaddr for ipaddr in ipaddress.summarize_address_range(startip, endip)]
    for cidr in cidrList:
        print(cidr) # print every cidr


