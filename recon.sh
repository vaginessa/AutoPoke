#!/bin/bash
TARGET="$1"
MODE="$2"

FIERCEFILE="/loot/fierce"
HARVESTERFILE="/loot/theharvester"
SUBLISTERFILE="/loot/sublister"
SUBBRUTEFILE="/loot/subbrute"
CHECKPWNFILE="/loot/checkpwn"


IPLIST="/loot/ip-list"
DOMAINLIST="/loot/domain-list"
DOMAINHTTPPORT="/loot/domains-with-http-port"
TEMP="temporary-file"

BRUTE="0" # by default we use brute force attacks


OKRED='\033[91m'
OKGREEN='\033[92m'
OKORANGE='\033[93m'
RESET='\e[0m'


function help {
    echo "Usage: $0 <target> [mode]"
    echo
    echo "Available modes:"
    echo "-nb no bruteforce"
    echo
    echo "Default mode is normal"
} 

function run-fierce {
    echo -e "$OKORANGE \n##### RUNNING FIERCE #####\n $RESET"

    if [ "$BRUTE" = "0" ]; then
        echo -e "$OKRED""NOTE: skipping brute force""$RESET"
        fierce -threads 8 -dns $TARGET -file $FIERCEFILE # -wide scans c class if any host in found in it, slow!
    else
        fierce -threads 8 -dns $TARGET -wide -file $FIERCEFILE # -wide scans c class if any host in found in it, slow!
    fi
}

function run-theharvester {
    echo -e "$OKORANGE \n##### RUNNING theHarvester #####\n $RESET"
    theharvester -d $TARGET -v -l 1000 -b all | tee $HARVESTERFILE # enumerate emails, subdomains, virtualhosts. check emails for leak
}

function run-sublister {
    echo -e "$OKORANGE \n##### RUNNING Sublist3r #####\n $RESET"
    if [ "$BRUTE" = "0" ]; then
        echo -e "$OKRED""NOTE: skipping brute force""$RESET"
        sublist3r.py -t 8 -d $TARGET --output $SUBLISTERFILE # enumerate subdomains and use subbrute module
    else
        sublist3r.py -b -t 8 -d $TARGET --output $SUBLISTERFILE # enumerate subdomains and use subbrute module - brute is slow! but it finds more things!
    fi
}

function run-subbrute {
    echo -e "$OKORANGE \n##### RUNNING SubBrute #####\n $RESET"
    echo -e "$OKRED""This will take a while...(several hours)""$RESET"
    subbrute.py $TARGET | tee $SUBBRUTEFILE
}

#########################################################################

# extract all unique ips to be able to scan them

function parse-ips {
    echo -e "$OKORANGE \n##### Parsing IP's #####\n $RESET"
    cat $FIERCEFILE $HARVESTERFILE $SUBLISTERFILE | ip_parser.py  >> $TEMP # THIS TAKES ALSO THE IPS FROM SUBNETS FIERCE SUGGESTS
    cat $FIERCEFILE $HARVESTERFILE $SUBLISTERFILE $SUBBRUTEFILE 2>/dev/null | domain_parser.py $TARGET | hostname_to_ip.py  >> $TEMP # also resolve every hostname because sublister doesnt
    cat $TEMP | sort | uniq > $IPLIST
    echo -e "$OKGREEN""Total unique ip's: $(wc -l < $IPLIST)""$RESET"
    rm $TEMP 
}

function parse-domains {
    echo -e "$OKORANGE \n##### Parsing Domains #####\n $RESET"
    cat $FIERCEFILE $HARVESTERFILE $SUBLISTERFILE $SUBBRUTEFILE 2>/dev/null | domain_parser.py $TARGET  >> $TEMP 
    cat $TEMP | sort | uniq > $DOMAINLIST
    echo -e "$OKGREEN""Total unique domains: $(wc -l < $DOMAINLIST)""$RESET"
    rm $TEMP 
}


##########################################################################

# normal nmap scan, all ports

function run-nmap {
    echo -e "$OKORANGE \n##### RUNNING Nmap #####\n $RESET"
    if [ "$BRUTE" = "0" ]; then
        echo -e "$OKRED""NOTE: skipping brute force""$RESET"
        nmap -A -p1-65335 -oA nmap \
        --script "ms-sql-empty-password,mysql-empty-password"\
        -iL $IPLIST # https://nmap.org/nsedoc/scripts/http-default-accounts.html // also try to find vhosts <- http-enum vois olla kans
    else
        nmap -A -p1-65335 -oA nmap \
        --script "http-vhosts,http-default-accounts,ms-sql-empty-password,mysql-empty-password"\
        -iL $IPLIST # https://nmap.org/nsedoc/scripts/http-default-accounts.html // also try to find vhosts
    fi
}

############################################################################

# parse nmap output to find hostnames and ports with http
# subdomain|port1,port2,port3..

function find-http {
    echo -e "$OKORANGE \n##### Searching subdomains with http #####\n $RESET"
    cat $DOMAINLIST | find_http.py nmap.xml >> $DOMAINHTTPPORT 
    echo -e "$OKGREEN""Total hosts with http service: $(wc -l < $DOMAINHTTPPORT)""$RESET"
}

############################################################################
        
function run-nikto {
    echo -e "$OKORANGE \n##### RUNNING Nikto #####\n $RESET"
    for i in $(cat $DOMAINHTTPPORT); do
        var1=$(echo $i | cut -d '|' -f1) # hostname
        var2=$(echo $i | cut -d '|' -f2) # comma separated ports
        nikto -host $var1 -port $var2 | tee $var1-nikto
    done
}

function run-sqlmap {
    echo -e "$OKORANGE \n##### RUNNING SQLMap #####\n $RESET"
    for i in $(cat $DOMAINHTTPPORT); do
        var1=$(echo $i | cut -d '|' -f1) # hostname
        var2=$(echo $i | cut -d '|' -f2) # comma separated ports
        sqlmap --threads=8 --crawl=5 --batch --smart --random-agent --forms --is-dba --dbs -u $var1 | tee $var1-$var2-sqlmap # TODO: port specification!
    done # the --risk is by default 1
}

function run-checkpwn {
    echo -e "$OKORANGE \n##### RUNNING CheckPwn #####\n $RESET"
    cat $HARVESTERFILE | check_pwn.py | tee $CHECKPWNFILE # take all emails from theharvester and check if any has been pwned
}



# validate params
if [ -z $TARGET ]; then
    echo "Usage: $0 <target> [mode]"
    echo "Try $0 --help for information"
    exit
fi
if [[ $TARGET = "--help" ]]; then
	help
	exit
fi
if [[ $MODE = "-nb" ]]; then
    echo -e "$OKRED""[INFO] - no bruteforce""$RESET"
    BRUTE="0"
fi

# start making noise!

echo -e "$OKGREEN""\nAUDITOR!!!""$RESET"

run-fierce
run-theharvester
run-sublister

if [ "$BRUTE" = "0" ]; then
    run-subbrute
fi

parse-ips
parse-domains

run-nmap
find-http
#run-nikto
run-checkpwn


echo -e "$OKGREEN \nOk, we're done here -- til' next time brother\n $RESET"

