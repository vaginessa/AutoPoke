# Disclaimer
**AutoPoke is for education/research purposes only. The author takes NO responsibility and/or liability for how you choose to use any of the tools/source code/any files provided. The author and anyone affiliated with will not be liable for any losses and/or damages in connection with use of ANY files provided with AutoPoke. By using AutoPoke or any files included, you understand that you are AGREEING TO USE AT YOUR OWN RISK. Once again AutoPoke and ALL files included are for EDUCATION and/or
RESEARCH purposes ONLY. AutoPoke is ONLY intended to be used on your own pentesting labs, or with explicit consent from the owner of the property being tested.**

# AutoPoke
AutoPoke is a tool to conduct basic penetration tests automatically.
The tool was developed to practice the author's bash and python scripting skills and to automate grunt work.
Provides good starting point for penetration test.


## How it works?
### 1. Subdomain enumeration

#### Fierce http://ha.ckers.org/fierce/
```
fierce -threads 8 -dns $TARGET

or

fierce -threads 8 -dns $TARGET -wide

* depending on if brute force is enabled
```

#### Sublist3r https://github.com/aboul3la/Sublist3r
```
sublist3r.py -t 8 -d $TARGET
or
sublist3r.py -b -t 8 -d $TARGET

* depending on if brute force is enabled
```

#### SubBrute https://github.com/TheRook/subbrute
```
subbrute.py $TARGET

* this is run only if brute force is enabled
```


### 2. Harvest email addresses

#### theHarvester
https://github.com/laramies/theHarvester
```
theharvester -d $TARGET -v -l 1000 -b all
```


### 3. Port scanning

#### Nmap https://github.com/nmap/nmap
```
nmap -A -p1-65335 -oA nmap \
    --script "ms-sql-empty-password,mysql-empty-password"\
    -iL $IPLIST

or

nmap -A -p1-65335 -oA nmap \
    --script "http-vhosts,http-default-accounts,ms-sql-empty-password,mysql-empty-password"\
    -iL $IPLIST

* depending on if brute force is enabled
```


### 4. Web server scanning

#### Nikto https://github.com/sullo/nikto
```
TODO
```


### 5. SQL injection scanning

#### SQLMap https://github.com/sqlmapproject/sqlmap
```
sqlmap --threads=8 --crawl=5 --batch --smart --random-agent --forms --is-dba --dbs -u $var1
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

### Arguments
TODO


## Limitations
As automated tool usually, AutoPoke has limitations.
TODO


## Future
Maybe add https://github.com/scipag/vulscan <- to make nmap detect vulnerabilities


