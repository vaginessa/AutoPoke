FROM kalilinux/kali-linux-docker

RUN apt-get update && apt-get install -y \
    fierce \
    nmap \
    theharvester \
    nikto \
    whatweb \
    wpscan \
    joomscan \
    python \
    python-pip \
    sqlmap \
    git \
    python-dnspython \
    && apt-get clean \
    && pip install pypwned termcolor


# Add paths
RUN echo 'export PATH=$PATH:/poke' >> ~/.bashrc && \
    echo 'export PATH=$PATH:/poke/tools' >> ~/.bashrc

# Sublist3r
RUN git clone https://github.com/aboul3la/Sublist3r.git && \
    cd Sublist3r && \
    pip install -r requirements.txt && \
    chmod +x sublist3r.py && \
    echo 'export PATH=$PATH:/Sublist3r' >> ~/.bashrc && \
    cd /

# python nmap library
RUN git clone https://github.com/savon-noir/python-libnmap.git && \
    cd python-libnmap && \
    python setup.py install && \
    cd /

# SubBrute
RUN git clone https://github.com/TheRook/subbrute.git && \
    echo 'export PATH=$PATH:/subbrute' >> ~/.bashrc && \
    cd /
    
  
# add scripts
ADD recon.sh /poke/
ADD tools/ip_parser.py /poke/tools/
ADD tools/domain_parser.py /poke/tools/
ADD tools/hostname_to_ip.py /poke/tools/
ADD tools/check_pwn.py /poke/tools/
ADD tools/find_http.py /poke/tools/


# add volume
VOLUME /loot

# Start container with bash shell
CMD /bin/bash
