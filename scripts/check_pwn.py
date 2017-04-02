#!/usr/bin/python

import sys
import re
import pypwned
import time
from termcolor import colored

emailregex = r'[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+'
emaillist = []

for line in sys.stdin:
    emaillist.extend(re.findall(emailregex, line))

for i in emaillist:
    print i + ': '

    breaches = pypwned.getAllBreachesForAccount(email=i)
    time.sleep(3)
    pastes = pypwned.getAllPastesForAccount(account=i)

    if type(breaches) is str:
        print colored('\tbreaches: ', "yellow") + colored(breaches, "red")
    else:
        print colored("\tbreaches:", "yellow")
        for item in breaches:
            print colored('\t>\t' + item['Domain'], "green")
            print colored('\t\t' + item['BreachDate'], "green")
            sys.stdout.write('\t\t')
            for data in item['DataClasses']:
                sys.stdout.write(colored(data + ',', "green"))
            print ''
            if item['IsFabricated']:
                print colored('\t\tFABRICATED', "red")
    sys.stdout.flush()

    if type(pastes) is str:
        print colored('\tpastes: ', "yellow") + colored(pastes, "red")
    else:
        print colored("\tPastes: ", "yellow")
        for item in pastes:
            print colored('\t>\t' + item['Id'], "green")
            if item['Date']:
                print colored('\t\tDate: ' + str(item['Date']), "green")
            print colored('\t\tEmails: ' + str(item['EmailCount']), "green")
    time.sleep(3) # sleep for 3 secs because of rate limiting


