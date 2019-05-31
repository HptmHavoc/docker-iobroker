FROM balenalib/rpi-raspbian:latest

#MAINTAINER Andre Germann <https://buanet.de>

ENV DEBIAN_FRONTEND noninteractive

#COPY qemu-arm-static /usr/bin

COPY scripts/iobroker_startup.sh scripts/setup_avahi.sh scripts/setup_packages.sh /opt/scripts/

# Install prerequisites
RUN echo "**** update and install packages ****" && \
    apt-get update && apt-get upgrade -y && apt-get install -y \
        acl \
        apt-utils \
        build-essential \
        curl \
        git \
        gnupg2 \
        libavahi-compat-libdnssd-dev \
        libcap2-bin \
        libpam0g-dev \
        libudev-dev \
        locales \
        procps \
        python \
        sudo \
        unzip \
        wget \
    && rm -rf /var/lib/apt/lists/* && \
echo "**** install node 8.16.0 armv6l ****" && \
    curl -o \
        /tmp/node.gz -L \
	        "https://nodejs.org/dist/latest-v8.x/node-v8.16.0-linux-armv6l.tar.gz" && \
        tar xfz \
	        /tmp/node.gz -C /tmp --strip 1 && \
    cd /tmp && \
    for dir in bin include lib share; do cp -par ${dir}/* /usr/local/${dir}/; done && \
    cd .. && \
echo "**** generating locales ****" && \
    sed -i 's/^# *\(de_DE.UTF-8\)/\1/' /etc/locale.gen && \
	&& sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen && \
	locale-gen && \
echo "**** create scripts directory and copy scripts ****" && \
#    mkdir -p /opt/scripts/ && \
    chmod 777 /opt/scripts/ && \
    chmod +x /opt/scripts/iobroker_startup.sh && \
	chmod +x /opt/scripts/setup_avahi.sh && \
    chmod +x /opt/scripts/setup_packages.sh && \
echo "**** install ioBroker ****" && \
    apt-get update && \
    curl -sL https://raw.githubusercontent.com/ioBroker/ioBroker/stable-installer/installer.sh | bash - && \
    echo $(hostname) > /opt/iobroker/.install_host && \
    echo $(hostname) > /opt/.firstrun && \
    rm -rf /var/lib/apt/lists/* &&\
echo "**** install node-gyp ****" && \
    npm config set unsafe-perm true && \
    npm install -g node-gyp --prefix /opt/iobroker/ && \
echo "**** backup initial ioBroker-folder ****" && \
    tar -cf /opt/initial_iobroker.tar /opt/iobroker && \
echo "**** setting up iobroker-user ****" && \
    chsh -s /bin/bash iobroker

# Setting up ENVs
ENV DEBIAN_FRONTEND="teletype" \
	LANG="de_DE.UTF-8" \
	LANGUAGE="de_DE:de" \
	LC_ALL="de_DE.UTF-8" \
	TZ="Europe/Berlin" \
	PACKAGES="nano" \
	AVAHI="false"

# Setting up EXPOSE for Admin
EXPOSE 8081/tcp	
	
# Run startup-script
ENTRYPOINT ["/opt/scripts/iobroker_startup.sh"]
