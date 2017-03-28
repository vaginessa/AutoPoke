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


# AutoPoke
RUN git clone https://github.com/ValtteriL/AutoPoke.git && \
    echo 'export PATH=$PATH:/AutoPoke' >> ~/.bashrc && \
    echo 'export PATH=$PATH:/AutoPoke/tools' >> ~/.bashrc


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
    

# add volume
VOLUME /loot

# Start container with bash shell
CMD /bin/bash
