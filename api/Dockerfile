FROM debian:jessie-slim

LABEL version="1.0" \
      date="2017-07-24"

MAINTAINER Sergio Sanchez Vega "ssanchez@s30labs.com"

RUN apt-get update && \

# Install base packases
    apt-get install -yq vim git php5 php5-json php5-cli php5-common php5-curl php-db mysql-client \
                        php-fpdf php-mail php-net-smtp php-net-socket php-pear php-xml-parser \
                        php5-dev php5-gd php5-mysql php5-raphf php5-raphf-dev \
                        php5-propro php5-propro-dev php5-xsl php5-ldap php5-imap php5-apcu && \
# Apache libs
    a2enmod ssl && \
    a2enmod rewrite && \
    a2enmod expires && \

# Clean all files downloaded
    apt-get clean && \
    apt-get autoclean && \
    rm -rf /var/lib/apt/lists/* && \

# CNM base directories
    mkdir -p /opt/cnm && \
    ln -s /usr/share/php /usr/share/pear && \

# Create CNM file log
    touch /var/log/apache2/cnm_gui.log && \
    chmod 666 /var/log/apache2/cnm_gui.log && \
    a2enmod expires && \
    a2enmod ssl && \
    a2enmod rewrite && \
    mkdir -p /opt/cnm

ADD files/etc/apache2/sites-enabled/000-default /etc/apache2/sites-enabled/000-default.conf
ADD files/etc/apache2/cnm_default.pem /etc/apache2/cnm_default.pem
ADD files/etc/apache2/apache2.conf /etc/apache2/apache2.conf
ADD files/opt/cnm/tphp /var/www/html/tphp
ADD files/cfg/onm.conf /cfg/onm.conf
ADD files/onm-api /opt/cnm/

EXPOSE 80 443
CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]

# ##### #
# STEPS #
# ##### #

# docker run --name cnm-mysql -v /home/ssanchez/Documents/cnm/data/files:/docker-entrypoint-initdb.d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.5

# docker run --rm -ti --name cnm-api --link cnm-mysql:mysql -p 8443:443 cnm-api bash
#       Edit /cfg/onm.conf and replace DB_SERVER with 172.17.0.2
#       mysql -u onm -h $MYSQL_PORT_3306_TCP_ADDR -ponm1234
#       /usr/sbin/apache2ctl -D FOREGROUND &
#       curl -ki "https://localhost/1.0/auth/token.json?u=admin&p=cnm123"

# O

# docker run --name cnm-mysql -v /home/ssanchez/Documents/cnm/data/files:/docker-entrypoint-initdb.d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.5
# docker run --rm -d --name cnm-api --link cnm-mysql:mysql -e DB_SERVER=`docker inspect -f '{{ .NetworkSettings.IPAddress }}' cnm-mysql` -p 8443:443 s30/cnm/api





########################
# docker run --name cnm-mysql -v /home/ssanchez/Documents/cnm/data/files:/docker-entrypoint-initdb.d -p 3306:3306 -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest
# docker run --name cnm-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:latest
#        docker exec -it cnm-mysql bash
#        docker logs cnm-mysql
#
# docker run --name cnm-mysql -e MYSQL_ROOT_PASSWORD=my-secret-pw -d mysql:5.5




# docker run --rm -ti --name cnm-api --link cnm-mysql:mysql -p 8443:443 cnm-api bash
#        root@1e3a93e969b8:/# env
#        HOSTNAME=1e3a93e969b8
#        MYSQL_ENV_MYSQL_ROOT_PASSWORD=my-secret-pw
#        TERM=xterm
#        MYSQL_ENV_GOSU_VERSION=1.7
#        MYSQL_PORT_3306_TCP_PORT=3306
#        MYSQL_PORT_3306_TCP=tcp://172.17.0.2:3306
#        PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
#        PWD=/
#        MYSQL_ENV_MYSQL_VERSION=5.7.18-1debian8
#        SHLVL=1
#        HOME=/root
#        MYSQL_NAME=/cnm-api/mysql
#        MYSQL_PORT_3306_TCP_PROTO=tcp
#        MYSQL_PORT_3306_TCP_ADDR=172.17.0.2
#        MYSQL_ENV_MYSQL_MAJOR=5.7
#        MYSQL_PORT=tcp://172.17.0.2:3306
#        _=/usr/bin/env
#
#       mysql -u root -h $MYSQL_PORT_3306_TCP_ADDR -p$MYSQL_ENV_MYSQL_ROOT_PASSWORD
#       mysql -u onm -h $MYSQL_PORT_3306_TCP_ADDR -ponm1234

#       /usr/sbin/apache2ctl -D FOREGROUND &
#       tail -f /var/log/apache2/error.log
#       curl -ki "https://localhost/1.0/auth/token.json?u=admin&p=cnm123"
