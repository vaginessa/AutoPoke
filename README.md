# Disclaimer
**AutoPoke is for education/research purposes only. The author takes NO responsibility and/or liability for how you choose to use any of the tools/source code/any files provided. The author and anyone affiliated with will not be liable for any losses and/or damages in connection with use of ANY files provided with AutoPoke. By using AutoPoke or any files included, you understand that you are AGREEING TO USE AT YOUR OWN RISK. Once again AutoPoke and ALL files included are for EDUCATION and/or
RESEARCH purposes ONLY. AutoPoke is ONLY intended to be used on your own pentesting labs, or with explicit consent from the owner of the property being tested.**

# AutoPoke
AutoPoke is a tool to conduct basic penetration tests automatically.
AutoPoke derives its firepower from well-known security tools.
The tool was developed to practice the author's bash and python scripting skills and to automate grunt work.
Provides good starting point for penetration test.


## How it works?
### 1. Subdomain enumeration
Subdomains of the target are enumerated using a couple of tools.

#### Fierce http://ha.ckers.org/fierce/
```
fierce -threads 8 -dns $TARGET [-wide]
```

#### Sublist3r https://github.com/aboul3la/Sublist3r
```
sublist3r.py [-b] -t 8 -d $TARGET
```

#### SubBrute https://github.com/TheRook/subbrute
```
subbrute.py $TARGET

* this is run only if brute force is enabled
```


### 2. Harvest email addresses

#### theHarvester https://github.com/laramies/theHarvester
```
theharvester -d $TARGET -v -l 1000 -b all
```


### 3. Port scanning
The subdomains are resolved to ip addresses and the addresses are used to generate ip ranges.
The ip ranges are scanned for open ports.

#### Nmap https://github.com/nmap/nmap
```
nmap -sV -sC -p1-65335 -oA nmap \
    --script "[http-vhosts,http-default-accounts],ms-sql-empty-password,mysql-empty-password"\
    -iL $IPLIST
```


### 4. Web server scanning
Where open http* services are detected, are requested using all subdomains that point to that host.
All unique web applications are grouped and only one of each different application is scanned using nikto.

#### Nikto https://github.com/sullo/nikto
```
nikto -host $var1 -port $var2 [-ssl]
```


### 5. SQL injection scanning
The same unique web applications that got scanned with nikto, are scanned using sqlmap.

#### sqlmap https://github.com/sqlmapproject/sqlmap
```
sqlmap --threads=8 --crawl=5 --batch --smart --random-agent --forms --is-dba --dbs -u http[s]://$var1:$var2/
```


### 6. Check emails for breaches
#### PyPwned https://github.com/icanhasfay/PyPwned
```
Checks the emails found with theHarvester against haveibeenpwned database
```


## Installation
Docker Installation:
```
docker pull valtteri/autopoke
```

## Usage
```
docker run --rm -it --volume ./loot:/loot valtteri/autopoke autopoke <example.com> [mode]

* the output files will be in the loot directory
```

### Modes
```
-nb    # No bruteforcing, much faster
```

## Limitations
As automated tools usually, AutoPoke has limitations.
Limitations include:
- might not find all subdomains -> might not scan whole range if the subdomain is highest/lowest
- might scan hosts that don't belong to target (if non-continuous ip-range in /24)
- might not identify every different web app as only /'s are compared


## Future
Maybe add https://github.com/scipag/vulscan <- to make nmap detect vulnerabilities


