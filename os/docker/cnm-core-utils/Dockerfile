# CNM Core Perl utils
# docker build --rm -t cnm-core-utils:1.0 .
FROM debian:buster-slim

LABEL maintainer="fmarin@s30labs.com"

# git clone https://github.com/s30labs/cnm.git
# git clone https://github.com/s30labs/cnm-extras.git
# git clone https://github.com/s30labs/cnm-mibs.git
# git pull

RUN  apt-get update && apt-get install -y ansible git perl gcc make autoconf libperl-dev \
	vim \
	libjson-perl \
	libwww-perl libwww-mechanize-perl \
	libmail-pop3client-perl libnet-imap-simple-perl libnet-imap-simple-ssl-perl \
	libnet-dns-perl libnet-dns-sec-perl \
	libnet-ldap-perl \
	libsoap-lite-perl \
	libclass-dbi-perl libclass-dbi-mysql-perl \
	libcapture-tiny-perl \
	libalgorithm-diff-perl \
	libnet-openssh-perl \
	librrds-perl \
        && rm -rf /var/lib/apt/lists/* \
	&& cd /opt && git clone https://github.com/s30labs/cnm-mibs.git \
	&& git clone https://github.com/s30labs/cnm-extras.git \
	&& git clone https://github.com/s30labs/cnm.git

#COPY ./cnm-mibs* /opt/cnm-mibs/
#COPY ./cnm/crawler/bin* /opt/crawler/bin/
#COPY ./cnm/os/docker* /opt/cnm/os/docker/
#COPY ./cnm-extras/src/net-snmp/net-snmp-5.*  /opt/cnm-extras/src/net-snmp/
##COPY ./cnm-extras/perl_modules*  /opt/cnm-extras/perl_modules/

RUN  mkdir -p /tmp/src/net-snmp/net-snmp-5.8 \
	&& tar -C /tmp/src/net-snmp -xzvf /opt/cnm-extras/src/net-snmp/net-snmp-5.8.tar.gz \
	&& cd /tmp/src/net-snmp/net-snmp-5.8 \
	&& ./configure --with-perl-modules --prefix=/opt/snmp --with-sys-contact="cnm-admin" --with-sys-location="CNM Room" --with-default-snmp-version="3" --with-logfile="/var/log/snmpd.log" --with-persistent-directory="/var/net-snmp" \
	&& make && make install && rm -rf /tmp/src/*


RUN  cd /opt/cnm/os/docker/automate && ansible-playbook -c local -i ./ansible.localhost --extra-vars "ansible_python_interpreter=/usr/bin/python3" cnm-snmp-client.yml

WORKDIR /opt/crawler/bin

CMD /bin/bash 



