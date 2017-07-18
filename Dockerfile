FROM debian:jessie
LABEL maintainer="Revenger: aka drguild"

ENV DEBIAN_FRONTEND=noninteractive

# Nomachine file download information
ENV NOMACHINE_PACKAGE_FULL_PATH \
    http://download.nomachine.com/download/5.3/Linux/nomachine_5.3.9_6_amd64.deb
ENV NOMACHINE_MD5 \
    050eadd9f037e31981c7e138bfcfbe80

# Build package list for install
ENV BUILD_PACKAGES \
    curl cups pulseaudio ssh vim xterm sudo \
    mate-desktop-environment-core mate-netspeed \
    eiskaltdcpp-gtk3 eiskaltdcpp-emoticons 

# Extra DC++ packages not installed here for referance
# eiskaltdcpp-scripts eiskaltdcpp-sounds php5-cli

# Build packages
RUN apt-get update && apt-get install -y $BUILD_PACKAGES \
    && rm -rf /var/lib/apt/lists/*

# Add additional files to the process
ADD nxserver.sh /

# NoMachine install and user add
# ** Note default change nomachine user and password at some stage to something better **
RUN curl -fSL "${NOMACHINE_PACKAGE_FULL_PATH}" -o nomachine.deb \
    && echo "${NOMACHINE_MD5} *nomachine.deb" | md5sum -c - \
    && dpkg -i nomachine.deb \
    && groupadd -r nomachine -g 433 \
    && useradd -u 431 -r -g nomachine -d /home/nomachine -s /bin/bash -c "NoMachine" nomachine \
    && mkdir /home/nomachine \
    && chown -R nomachine:nomachine /home/nomachine \
    && echo 'nomachine:nomachine' | chpasswd \
    && rm -f nomachine.deb \
    && service ssh start \
    && chmod +x /nxserver.sh

# Root Password change 'needed to access nomachine settings'
Run echo 'root:docker' | chpasswd

ENTRYPOINT ["/nxserver.sh"]

EXPOSE 22 4000
