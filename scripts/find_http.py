#!/usr/bin/python3

#
# input: nmap scan results as xml, hostname-to-ip pickle
#
# output: hostname|port|isHttps of every unique website
#

import sys
import socket
import ssl
import pickle
from urllib.request import urlopen
import hashlib
from libnmap.parser import NmapParser
from termcolor import colored


if len(sys.argv) != 3:
    print('Usage: ' + sys.argv[0] + ' <nmap-report.xml> <filename>')
    sys.exit(0)

nmap_report = NmapParser.parse_fromfile(sys.argv[1])

ipPortList = [] # (ip, [port], isHttps)


# populate the ipPortList from scanned hosts
for scanned_host in nmap_report.hosts:
    for ops in scanned_host.services:
        if (ops.service == 'https' or ops.service == 'https-alt') and ops.open():
            gotAssigned = False
            for ips in ipPortList:
                if ips[0] == str(scanned_host) and ips[2] == True:
                    ips[1].append(str(ops.port))
                    gotAssigned = True
                    break
            if not gotAssigned:
                ipPortList.append((str(scanned_host.address), [str(ops.port)], True)) # add port to list
        elif (ops.service == 'http' or ops.service == 'http-alt') and ops.open():
            gotAssigned = False
            for ips in ipPortList:
                if ips[0] == str(scanned_host) and ips[2] == False:
                    ips[1].append(str(ops.port))
                    gotAssigned = True
                    break
            if not gotAssigned:
                ipPortList.append((str(scanned_host.address), [str(ops.port)], False)) # add port to list


# get the previously saved list of (hostname, ip)
with open(sys.argv[2], 'rb') as f:
    ipToHostname = pickle.load(f)


webappgroups = [] # ([subdomains], ip, [ports], isHttps)

# dont check validity of ssl certs
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE


#
for ipPort in ipPortList:
    hostPortDoc = [] # ([subdomain], [port], document, isHttps)
    for hostip in ipToHostname:
        if ipPort[0] == hostip[1]: # same ip
            for port in ipPort[1]: # for every open port with http* service

                try:
                    # request / and use https where https service
                    if ipPort[2]:
                        handle = urlopen('https://' + hostip[0] + ':' + port + '/', context=ctx)
                    else:
                        handle = urlopen('http://' + hostip[0] + ':' + port + '/')

                    content = handle.read()
                    contenthash = hashlib.md5(content).hexdigest()

                    # check if there's matching documents
                    gotAssingned = False
                    for hpd in hostPortDoc:
                        if hpd[2] == contenthash: # if content is identical, we dont care if its https or not
                            hpd[0].append(hostip[0])
                            hpd[1].append(port)
                            hpd[1] = list(set(hpd[1]))
                            gotAssigned = True
                            break
                    if not gotAssigned:
                        hostPortDoc.append(([hostip[0]], [port], contenthash, ipPort[2]))

                except Exception as e:
                    print(colored(hostip[0] + ':' + port + ' ' + str(e) + ', skipping', 'red'), file=sys.stderr)
                    pass


    if not hostPortDoc: # no subdomain points to this ip, request it by ip
        for port in ipPort[1]: # for every open port with http* service

            try:
                if ipPort[2]:
                    handle = urlopen('https://' + ipPort[0] + ':' + port + '/', context=ctx)
                else:
                    handle = urlopen('http://' + ipPort[0] + ':' + port + '/')

                content = handle.read()
                contenthash = hashlib.md5(content).hexdigest()

                # check if there's matching documents
                gotAssingned = False
                for hpd in hostPortDoc:
                    if hpd[2] == contenthash: # if content is identical, we dont care if its https or not
                        hpd[0].append(ipPort[0])
                        hpd[1].append(port)
                        hpd[1] = list(set(hpd[1]))
                        gotAssigned = True
                        break
                if not gotAssigned:
                    hostPortDoc.append(([ipPort[0]], [port], contenthash, ipPort[2]))

            except Exception as e:
                print(colored(ipPort[0] + ':' + port + ' ' + str(e) + ', skipping', 'red'), file=sys.stderr)
                pass


    # nyt pitais olla sit: [([subdomain], [port], document, isHttps), ...]

    # append the groups of different web apps to list
    for hpd in hostPortDoc:
        webappgroups.append((hpd[0], ipPort[0], hpd[1], hpd[3]))


# print first
print(colored('Unique web apps identified','green'), file=sys.stderr)
for webapp in webappgroups:
    print(colored(str(webapp),'green'), file=sys.stderr)
    print(str(webapp[0][0]) + '|' + str(webapp[2][0]) + '|' + str(webapp[3]))

